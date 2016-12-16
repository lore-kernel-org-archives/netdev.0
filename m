From: David Miller <davem@davemloft.net>
Subject: Re: [TSN RFC v2 0/9] TSN driver for the kernel
Date: Fri, 16 Dec 2016 13:20:57 -0500 (EST)
Message-ID: <20161216.132057.1771215556712298530.davem@davemloft.net>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
        <1481911964.3572.1.camel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: henrik@austad.us, linux-kernel@vger.kernel.org,
        richardcochran@gmail.com, haustad@cisco.com,
        linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: gvrose8192@gmail.com
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1481911964.3572.1.camel@gmail.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg <gvrose8192@gmail.com>
Date: Fri, 16 Dec 2016 10:12:44 -0800

> On Fri, 2016-12-16 at 18:59 +0100, henrik@austad.us wrote:
>> From: Henrik Austad <haustad@cisco.com>
>> 
>> 
>> The driver is directed via ConfigFS as we need userspace to handle
>> stream-reservation (MSRP), discovery and enumeration (IEEE 1722.1) and
>> whatever other management is needed. This also includes running an
>> appropriate PTP daemon (TSN favors gPTP).
> 
> I suggest using a generic netlink interface to communicate with the
> driver to set up and/or configure your drivers.
> 
> I think configfs is frowned upon for network drivers.  YMMV.

Agreed.
