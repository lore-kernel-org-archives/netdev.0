From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH 1/8][BNX2X] resubmit as attachments: add bnx2x to
 Kconfig and Makefile
Date: Tue, 09 Oct 2007 06:13:23 +0200
Message-ID: <470AFFE3.100@broadcom.com>
References: <470A5795.2000809@broadcom.com>
 <20071008.174603.55855492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, mchan@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3230 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbXJIENg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 00:13:36 -0400
In-Reply-To: <20071008.174603.55855492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Eliezer Tamir" <eliezert@broadcom.com>
> Date: Mon, 08 Oct 2007 18:15:17 +0200
> 
>> Add bnx2x to Kconfig and Makefile
> 
> In a patch submission, the tree should build on every step along the
> way in applying your patches, with any given configuration.
> 
> Here, the user (or something automated like "make allmodconfig") can
> select the new config option, but because the driver source hasn't
> been added, the compile will fail.
> 
> The idea is that if your patch set really is composed of logically
> seperate changes, you submit them one logical compilable piece at a
> time, and if the first few patches are ok, they could go right in
> whilst we work out issues in later patches.  But that's not how
> a new driver is, it is logically one change only.
> 
> You go on next to add a foo.c file, and then a foo.h file.
> This makes things even more difficult to review.
> 
> Really, for a new driver that doesn't make any generic kernel code
> changes, just submit the whole thing in one shot.  It's the only
> reasonable way.
> 
> Thank you.
> 

Due to the size of the patch I can not post it to the list.

Here is an FTP link.
ftp://Net_sys_anon@ftp1.broadcom.com/bnx2x-0.40.10-net-2.6.24-one.patch.txt

Or if you prefer, I can post it gzipped.

Thanks
Eliezer


