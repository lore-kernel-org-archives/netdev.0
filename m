From: Wolfgang Denk <wd@denx.de>
Subject: Re: tehuti: use resource_size_t instead of unsigned long and u32
Date: Fri, 05 Sep 2008 14:25:24 +0200
Message-ID: <20080905122524.63FF0242FF@gemini.denx.de>
References: <1220390068-6433-1-git-send-email-yanok@emcraft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, dzu@denx.de
To: Ilya Yanok <yanok@emcraft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:34497 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbYIEMZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 08:25:26 -0400
In-reply-to: <1220390068-6433-1-git-send-email-yanok@emcraft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Ilya Yanok,

In message <1220390068-6433-1-git-send-email-yanok@emcraft.com> you wrote:
> Use resource_size_t for pci_resource_start() and pci_resource_len() return
> values. Makes tehuti driver work correctly on 32 bit systems with 64 bit
> resources.
> 
> Signed-off-by: Ilya Yanok <yanok@emcraft.com>
> ---
>  drivers/net/tehuti.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)

Applied to master branch of linux-2.6-denx repo.

Thanks.

Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
The only perfect science is hind-sight.
