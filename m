From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v3 2/4] net: add rx_nohandler stat counter
Date: Mon, 08 Feb 2016 14:57:40 -0800
Message-ID: <1454972260.7627.368.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454370667-2328-1-git-send-email-jarod@redhat.com>
	 <1454370667-2328-3-git-send-email-jarod@redhat.com>
	 <20160207113732.25a88cc4@xeon-e3>
	 <20160207.144648.750890874940574761.davem@davemloft.net>
	 <1454876368.7627.350.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160208183254.GB4566@redhat.com> <20160208113821.0ba26eb0@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarod Wilson <jarod@redhat.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160208113821.0ba26eb0@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-02-08 at 11:38 -0800, Stephen Hemminger wrote:

> The iproute2 command can be fixed, but adding dependency on size of response
> gets gross fast.  Imagine when 4 more fields get added, this doesn't scale well.

Really ? I see no problem at all doing the proper tests.

> 
> Also, the definition of userspace ABI is that structures can't change.
> There are many other utilities that are not visible that may get broken.
> Traditionally Linux has guaranteed that programs will continue to work
> no matter how they were coded.

Stephen, we have been doing that for years.

Whole point of TLV is that it allows us to add new fields at the end of
the structures.

Yes, some buggy programs might need a fix.

Look at iproute2, you were the one adding in 2004 code to cope with
various tcp_info sizes.

So 12 years later, you cannot say it does not work anymore.
