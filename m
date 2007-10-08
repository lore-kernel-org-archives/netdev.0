From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BNX2X RESUBMIT][PATCH 0/8] New driver for Broadcom 10Gb
 Ethernet, take two.
Date: Mon, 8 Oct 2007 10:29:19 -0700
Message-ID: <20071008102919.1cbc7983@freepuppy.rosehill>
References: <470A23E5.6030102@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>, eilong@broadcom.com,
	vladz@broadcom.com, gertner@broadcom.com
To: "Eliezer Tamir" <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45794 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753661AbXJHRa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 13:30:58 -0400
In-Reply-To: <470A23E5.6030102@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 08 Oct 2007 14:34:45 +0200
"Eliezer Tamir" <eliezert@broadcom.com> wrote:

> [resubmitting, this time without line breaks, sorry]
> 
> This is an initial version of the BNX2X, the Linux driver for the
> BCM5771X 10Gb Ethernet controller family.
>  
> Although the chip is very different from the 5706-8 family we based the
> driver code on the BNX2 driver.
>  
> Since the hardware is supposed to be generally available soon I have
> posted an initial version and after hearing all the comments I am 
> reposting with changes to address them.
>  
> Some planned feature are still under development, but we want to get
> whatever we have out now so people can start using the HW.
> 
> Main changes from first version.
> 
> * Fixed most issues raised by Michael Buesch. (Thanks Michael!)
> * Some slow path bug fixes.
> * Yitchak Gertner re-grouped the code in a more logical manner.
> * A lot of work was done to get the generated code to comply with coding 
> style requirements.
> 
> Known issues/TODO.
> * Move slowpath event handling from tasklet to workqueue context. This 
> will allow replacing the busy waits in the link management code with sleeps.
> 
> Please consider applying to 2.6.24
> 
> Thanks
> Eliezer


Looks good.  Some minor stuff:
* You can use network device stats in network device structure and
  no longer need the copy in bp
* The MACRO's for 64 bit stats look like they could be done with 
  u64 and/or turned into inline's.
* RCS/CVS tags for date and version # are kind of ugly. They git system
  doesn't use them, perhaps you just want to track your internal version
  control information, but what happens when changes come from outside?


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
