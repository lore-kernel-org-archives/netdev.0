From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH] wireless: delete non-required instances of include <linux/init.h>
Date: Fri, 03 Jan 2014 01:29:16 +0100
Message-ID: <7093338.RGBiBKGbAL@debian64>
References: <1388707112-5669-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:38894 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbaACA3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:29:30 -0500
In-Reply-To: <1388707112-5669-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, January 02, 2014 06:58:32 PM Paul Gortmaker wrote:
> None of these files are actually using any __init type directives
> and hence don't need to include <linux/init.h>.  Most are just a
> left over from __devinit and __cpuinit removal, or simply due to
> code getting copied from one driver to the next.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
Acked-by: Christian Lamparter <chunkeey@googlemail.com>

for p54 and carl9170 parts.

Thanks,

Christian
