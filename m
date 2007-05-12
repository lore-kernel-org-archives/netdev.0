From: James Bottomley <James.Bottomley@SteelEye.com>
Subject: Re: default y idiocy
Date: Sat, 12 May 2007 15:56:12 -0500
Message-ID: <1179003373.3723.34.camel@mulgrave.il.steeleye.com>
References: <20070512182343.GO4629@kernel.dk>
	 <46461C77.5040404@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hancock.steeleye.com ([71.30.118.248]:58406 "EHLO
	hancock.sc.steeleye.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752892AbXELU4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2007 16:56:34 -0400
In-Reply-To: <46461C77.5040404@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-05-12 at 20:58 +0100, Simon Arlott wrote:
> On 12/05/07 19:23, Jens Axboe wrote:
> > Hi,
> > 
> > This has bothered me for a long time, and it just seems to be getting
> > worse. Can people please STOP defaulting non-essential stuff to 'y'?
> > Grrr.
> 
> Is there a reason why various 10/100/1000Mbit network cards are 'y' too?
> There's even a default SCSI 'm' that seems to be completely hidden from 
> the menu too (CONFIG_SCSI_WAIT_SCAN). It depends on SCSI but I can't 
> disable SCSI...

That might not necessarily be our fault ... there's no default 'm' for
SCSI in drivers/scsi/Kconfig.  On the other hand, the select directive
can also be the cause of these problems, for instance
drivers/ata/Kconfig has a select SCSI at the top, so if you selected
modular ATA, you'll be forced to have modular SCSI.

James


