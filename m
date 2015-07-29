From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: switchdev: restrict vid range abstraction
Date: Wed, 29 Jul 2015 12:28:50 -0700 (PDT)
Message-ID: <20150729.122850.41892076269756846.davem@davemloft.net>
References: <CAE4R7bA5jh3Rgn_U1Sit3qW+i2vKNE++c9TYTJ8sp5j8h=awbw@mail.gmail.com>
	<20150729.112842.1871916445536378243.davem@davemloft.net>
	<117624450.145106.1438197245281.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <117624450.145106.1438197245281.JavaMail.zimbra@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 29 Jul 2015 15:14:05 -0400 (EDT)

> While a range might be convenient to a user, exposing it to drivers is
> likely to end up writing the same vid_begin to vid_end for loop.

It is impossible not to expose this to the driver.

We have to have a prepare/commit sequence where the prepare part
can see the whole of the request.

It must know the full set of changes it must be able to support
in one go in order to signal a failure properly.

So in fact this is the most convenient way for the drivers to be
exposed to this issue.
