From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH 1/2] Added information about which firmware file is being
 requested.
Date: Wed, 19 Sep 2012 22:42:14 +0400
Message-ID: <505A1206.4020606@msgid.tls.msk.ru>
References: <1348053493-22955-1-git-send-email-jarl@softace.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stefano Brivio <stefano.brivio@polimi.it>,
	=?ISO-8859-1?Q?G=E1bor_S?= =?ISO-8859-1?Q?tefanik?=
	<netrolller.3d@gmail.com>, linux-wireless@vger.kernel.org,
	b43-dev@lists.infradead.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Jarl Friis <jarl@softace.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:37316 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756812Ab2ISSmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 14:42:16 -0400
In-Reply-To: <1348053493-22955-1-git-send-email-jarl@softace.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.09.2012 15:18, Jarl Friis wrote:

> +	b43info(ctx->dev->wl, "Requesting firmware file '%s'\n", ctx->fwname);
>  	err = request_firmware(&blob, ctx->fwname, ctx->dev->dev->dev);

Hmm.  I wonder if this should be printed in request_firmware()
itself instead of in all callers?

/mjt
