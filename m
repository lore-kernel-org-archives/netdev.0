From: Gertjan van Wingerde <gwingerde@gmail.com>
Subject: Re: [PATCH] wireless: delete non-required instances of include <linux/init.h>
Date: Fri, 3 Jan 2014 14:32:43 +0100
Message-ID: <61233E8B-3101-4CDB-9F32-FA775C9186AD@gmail.com>
References: <1388707112-5669-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:64137 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbaACNcr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 08:32:47 -0500
In-Reply-To: <1388707112-5669-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Sent from my iPad

> On 3 jan. 2014, at 00:58, Paul Gortmaker <paul.gortmaker@windriver.com> wrote:
> 
> None of these files are actually using any __init type directives
> and hence don't need to include <linux/init.h>.  Most are just a
> left over from __devinit and __cpuinit removal, or simply due to
> code getting copied from one driver to the next.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

For the rt2x00 parts:
Acked-by: Gertjan van Wingerde <gwingerde@gmail.com>

---
Gertjan