From: "stanley.miao" <stanley.miao@windriver.com>
Subject: Re: [PATCH] smsc911x: add irq_flags in smsc911x_platform_config.
Date: Thu, 15 Jan 2009 10:16:54 +0800
Message-ID: <1231985814.6810.15.camel@localhost>
References: <1231910512-8420-1-git-send-email-stanley.miao@windriver.com>
	 <20090114170633.GG22976@n2100.arm.linux.org.uk>
Reply-To: stanley.miao@windriver.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33109 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552AbZAOCIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 21:08:40 -0500
In-Reply-To: <20090114170633.GG22976@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 17:06 +0000, Russell King - ARM Linux wrote:
> On Wed, Jan 14, 2009 at 01:21:52PM +0800, Stanley.Miao wrote:
> > When calling request IRQ it is desirable to allow platforms
> > to specific flags for the call to request_irq. Adding irq_flags
> > to smsc911x_platform_config allows these flags to be passed.
> > 
> > Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>
> > ---
> >  drivers/net/smsc911x.c   |    6 ++++--
> >  include/linux/smsc911x.h |    1 +
> >  2 files changed, 5 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> > index f513bdf..1092517 100644
> > --- a/drivers/net/smsc911x.c
> > +++ b/drivers/net/smsc911x.c
> > @@ -1896,6 +1896,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
> >  	unsigned int intcfg = 0;
> >  	int res_size;
> >  	int retval;
> > +	irq_flags;
> 
> This looks wrong.

Sorry, I have send the V2 version. I should send a notice to ignore this
email.

Stanley

