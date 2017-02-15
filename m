From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] PTP attribute handling cleanup
Date: Wed, 15 Feb 2017 12:22:15 -0500 (EST)
Message-ID: <20170215.122215.823469813998299884.davem@davemloft.net>
References: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: dmitry.torokhov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Date: Tue, 14 Feb 2017 10:23:30 -0800

> PTP core was creating some attributes, such as "period" and "fifo", and the
> entire "pins" attribute group, after creating class deevice, which creates
> a race for userspace: uevent may arrive before all attributes are created.
> 
> This series of patches switches PTP to use is_visible() to control
> visibility of attributes in a group, and device_create_with_groups() to
> ensure that attributes are created before we notify userspace of a new
> device.

Richard, please review.
