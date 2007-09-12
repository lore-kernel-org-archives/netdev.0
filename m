From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Move the definition of pr_err() into kernel.h
Date: Wed, 12 Sep 2007 12:59:15 +0200
Message-ID: <20070912125915.5b5d8aa5@oldman>
References: <11895225651521-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	i2c@lm-sensors.org, linux-omap-open-source@linux.omap.com,
	Emil Medve <Emilian.Medve@Freescale.com>
To: Emil Medve <Emilian.Medve@Freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33033 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764265AbXILK7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:59:23 -0400
In-Reply-To: <11895225651521-git-send-email-Emilian.Medve@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Sep 2007 09:56:05 -0500
Emil Medve <Emilian.Medve@Freescale.com> wrote:

> Other pr_*() macros are already defined in kernel.h, but pr_err() was defined
> multiple times in several other places
> 
> Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>

pr_error seems better than pr_err

Please add the full set:
	pr_alert
	pr_critical
        pr_error
        pr_warn
        pr_notice


