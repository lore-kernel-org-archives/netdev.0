From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] e1000e: fix debugging printout code
Date: Mon, 15 Oct 2007 09:00:21 -0700
Message-ID: <1192464021.4556.49.camel@localhost>
References: <20071004183843.31540.23710.stgit@localhost.localdomain>
	 <47067A2F.5020603@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3830 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753876AbXJOQAg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 12:00:36 -0400
In-Reply-To: <47067A2F.5020603@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-10-05 at 13:53 -0400, Jeff Garzik wrote:
> > diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
> > index 848217a..aa82f1a 100644
> > --- a/drivers/net/e1000e/hw.h
> > +++ b/drivers/net/e1000e/hw.h
> > @@ -852,7 +852,7 @@ struct e1000_hw {
> >  
> >  #ifdef DEBUG
> >  #define hw_dbg(hw, format, arg...) \
> > -	printk(KERN_DEBUG, "%s: " format, e1000_get_hw_dev_name(hw), ##arg);
> > +	printk(KERN_DEBUG, "%s: " format, e1000e_get_hw_dev_name(hw), ##arg);
> 
> I will apply this, but, I strongly encourage deletion of this in favor 
> of the existing dev_dbg()

Instead the fix should be for the 2 existing bugs on macro:

o Comma after KERN_DEBUG
o Semicolon in macro

