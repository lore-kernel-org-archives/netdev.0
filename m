From: "Timur Tabi" <timur@freescale.com>
Subject: Re: [PATCH] ucc_geth: use correct UCCE macros
Date: Wed, 7 Jan 2009 14:17:04 -0600
Message-ID: <ed82fe3e0901071217y44900869n7af2e99d6174fd45@mail.gmail.com>
References: <1231359172-6119-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, leoli@freescale.com, davem@davemloft.net,
	galak@kernel.crashing.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:53969 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510AbZAGURF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 15:17:05 -0500
Received: by qw-out-2122.google.com with SMTP id 3so7528077qwe.37
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2009 12:17:04 -0800 (PST)
In-Reply-To: <1231359172-6119-1-git-send-email-timur@freescale.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2009 at 2:12 PM, Timur Tabi <timur@freescale.com> wrote:

> This patch will break ucc_geth.c if my other patch, "powerpc: add Ethernet
> UPSMR definitions to QE library" isn't also applied.  That patch is currently
> in Kumar's 'next' branch, so it will make 2.6.29-rc0.  Therefore, it should
> be safe to apply this patch to 'net-next' today, with the understanding that
> everything will be peachy once Linus pulls everyone's 2.6.29 branches.

David,

as I mentioned here, Kumar already has the pre-req patch in his 'next'
branch (for 2.6.29), so if you apply this patch to your 'next',
ucc_geth.c will break until Linus pulls from Kumar and you pull from
Linus.  I think that's OK.

-- 
Timur Tabi
Linux kernel developer at Freescale
