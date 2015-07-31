From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 v2] bridge fdb: add 'use' option to set NTF_USE
 flag in fdb add requests
Date: Fri, 31 Jul 2015 10:05:23 +0200
Message-ID: <55BB2C43.5060804@cumulusnetworks.com>
References: <1438292222-45993-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35076 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbbGaIF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 04:05:27 -0400
Received: by wibxm9 with SMTP id xm9so22454895wib.0
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 01:05:26 -0700 (PDT)
In-Reply-To: <1438292222-45993-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/2015 11:37 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This is similar to command options corresponding to other NTF_* flags
> already exposed to the user space (examples self/master).
> 
> Also updates bridge man page (The man page patch also includes
> a fix to the 'self' entry and documents 'master' for fdb entries)
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> v1-v2 : fixed usage
> 
>  bridge/fdb.c      |    7 +++++--
>  man/man8/bridge.8 |   15 ++++++++++++---
>  2 files changed, 17 insertions(+), 5 deletions(-)

Nice, now I won't have to patch iproute2 to test with NTF_USE. :-)

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
