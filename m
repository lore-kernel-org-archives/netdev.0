From: ext Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Add ability to register class interfaces for network class
Date: Wed, 27 Oct 2004 12:13:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027111317.GA27240@infradead.org>
References: <20041026183526.GA23535@two.research.nokia.com> <20041026184838.GB16621@infradead.org> <20041026205239.GA23825@two.research.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ext Christoph Hellwig <hch@infradead.org>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Teras Timo (EXT-YomiGroup/Helsinki)" <Ext-Timo.Teras@nokia.com>
Content-Disposition: inline
In-Reply-To: <20041026205239.GA23825@two.research.nokia.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I pointed out the reason why I need it: to add an attribute:
> /sys/class/net/<interface>/<new_attribute>. Others might want to do this
> too.
> 
> Also the interface subsystem is used in many places (eg. i2o) to create
> all the sysfs entries. Maybe it'd be useful to do in net class as well.
> And if'd make separate interfaces for standard attributes and wireless
> attributes. That way you'd get rid of the #ifdefs of WIRELESS_EXT in
> net-sysfs.c.
> 
> On the other hand you didn't answer my question: why the
> interface registration should not be possible?
> Documentation/driver-model/interface.txt states that this is exactly the
> thing it should be used for.

Because we don't add interfaces for the sake of it. You still haven't show
the user that wants this.  i you presented a sane user the review would be
quite different.
