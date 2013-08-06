From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] net: remove an unneeded check
Date: Tue, 6 Aug 2013 15:04:42 +0300
Message-ID: <20130806120442.GR5051@mwanda>
References: <20130729191519.GA11874@elgon.mountain>
 <F3E01662-FC33-4FB8-AF30-47DF44252296@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"<kernel-janitors@vger.kernel.org>" <kernel-janitors@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25312 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755449Ab3HFMFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 08:05:31 -0400
Content-Disposition: inline
In-Reply-To: <F3E01662-FC33-4FB8-AF30-47DF44252296@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 05, 2013 at 06:18:01PM +0000, Rustad, Mark D wrote:
> On Jul 29, 2013, at 12:15 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> > "ifa->ifa_label" is an array inside the in_ifaddr struct.  It can never
> > be NULL so we can remove this check.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> > index 8d48c39..1b7f7ae 100644
> > --- a/net/ipv4/devinet.c
> > +++ b/net/ipv4/devinet.c
> > @@ -1124,10 +1124,7 @@ static int inet_gifconf(struct net_device *dev, char __user *buf, int len)
> > 		if (len < (int) sizeof(ifr))
> > 			break;
> > 		memset(&ifr, 0, sizeof(struct ifreq));
> > -		if (ifa->ifa_label)
> 
> Is there any possibility that this was meant to check ifa->ifa_label[0]?

It has been this way for almost 16 years and no one has complained.
I should have put that into the changelog though, you are right.

regards,
dan carpenter
