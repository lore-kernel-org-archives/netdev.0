From: "Pekka J Enberg" <penberg@cs.helsinki.fi>
Subject: Re: net: generic netdev_ioaddr
Date: Fri, 29 Oct 2004 21:50:20 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <courier.418290EC.00002E85@courier.cs.helsinki.fi>
References: <1099044244.9566.0.camel@localhost>
            <20041029131607.GU24336@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="utf-8,iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20041029131607.GU24336@parcelfarce.linux.theplanet.co.uk>
To: Al Viro <viro@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, 

Al Viro writes:
> NAK.  ->base_addr casting is a Bad Idea(tm) and natsemi "solution" isn't
> (thanks for spotting that crap in natsemi, though; will fix...) 
> 
> Note that there is no such thing as "generic IO base address" - it _is_
> private and in the best case current ->base_addr is a scratch register
> probably used for something vaguely connected with some IO, but it's
> really up to driver...

Yup, I thought about that after I sent the patch. However, as it stands now, 
many network drivers use netdev->base_addr for just that.  Perhaps it should 
be nuked completely instead? 

            Pekka 
