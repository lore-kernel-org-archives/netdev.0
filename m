From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [PATCH 12/15] sis900: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 19:10:10 +0200
Message-ID: <B33AC648-AF69-4FA1-8E46-465DCEE29C3D@brownhat.org>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com> <1473689026-6983-13-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Javier Martinez Canillas <javier@osg.samsung.com>,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh2.infomaniak.ch ([128.65.195.6]:49389 "EHLO
        smtp-sh2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756146AbcILRS6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 13:18:58 -0400
In-Reply-To: <1473689026-6983-13-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12 September 2016 16:03:43 CEST, Javier Martinez Canillas <javier@osg.samsung.com> wrote:
>The IS_ENABLED() macro checks if a Kconfig symbol has been enabled
>either
>built-in or as a module, use that macro instead of open coding the
>same.
>
>Using the macro makes the code more readable by helping abstract away
>some
>of the Kconfig built-in and module enable details.
>
>Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

Acked-by: Daniele Venzano <venza@brownhat.org>
