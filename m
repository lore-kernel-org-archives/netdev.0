From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: [BNX2X][PATCH 0/8] New driver for Broadcom 10Gb Ethernet, take
	two.
Date: Sun, 7 Oct 2007 23:50:55 +0300
Message-ID: <20071007205055.GG6372@mea-ext.zmailer.org>
References: <47090768.4020307@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>, eilong@broadcom.com,
	vladz@bradcom.com, gertner@bradcom.com
To: Eliezer Tamir <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:54192 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbXJGUvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 16:51:00 -0400
Received: (mea@mea-ext) by mail.zmailer.org id S2261863AbXJGUuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 23:50:55 +0300
Content-Disposition: inline
In-Reply-To: <47090768.4020307@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 07, 2007 at 06:20:56PM +0200, Eliezer Tamir wrote:
> This is an initial version of the BNX2X, the Linux driver for the
> BCM5771X 10Gb Ethernet controller family.
> Although the chip is very different from the 5706-8 family we based the
> driver code on the BNX2 driver.
> Since the hardware is supposed to be generally available soon I have
> posted an initial version and after hearing all the comments I am reposting 
> with changes to address them.
> Some planned feature are still under development, but we want to get
> whatever we have out now so people can start using the HW.

Your patch-posting procedure is yet in a bit problem state..

 +{
 +static const u32 EVST_TSEM_FAST_MEMORY_COMMON_MEMORY_INIT_EMULATION_7[] = {
 +0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 
 0x0, 0x0,
 +0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 
 0x0, 0x0,
 +0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 
 0x0, 0x0,

It does look like your Thunderbird 2.0 did wrap long text lines when you
included the texts into the posts.

The result is that currently your patches are not usable at all.

Your options:
   - instead of including the patch in message body, use Attach
   - use some other email program that does not scramble your texts
     (e.g. mutt + emacs)
   - publish the patch file on network somewhere, and just tell URL
     to that one in email

> Main changes from first version.
>
> * Fixed most issues raised by Michael Buesch. (Thanks Michael!)
> * Some slow path bug fixes.
> * Yitchak Gertner re-grouped the code in a more logical manner.
> * A lot of work was done to get the generated code to comply with coding 
> style requirements.
>
> Known issues/TODO.
> * Move slowpath event handling from tasklet to workqueue context. This will 
> allow replacing the busy waits in the link management code with sleeps.
>
> Please consider applying to 2.6.24
>
> Thanks
> Eliezer

/Matti Aarnio  -- one of  <postmaster@vger.kernel.org>
