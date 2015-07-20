From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: "ss -p" segfaults
Date: Mon, 20 Jul 2015 20:14:17 +0200
Message-ID: <87mvyqelxi.fsf@igel.home>
References: <55AC9E8C.7040200@openmailbox.org>
	<55AD3073.3000302@openmailbox.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: "j.ps\@openmailbox.org" <j.ps@openmailbox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:34917 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbbGTSOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 14:14:20 -0400
In-Reply-To: <55AD3073.3000302@openmailbox.org> (j.ps@openmailbox.org's
	message of "Mon, 20 Jul 2015 18:31:31 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"j.ps@openmailbox.org" <j.ps@openmailbox.org> writes:

> -			free(p->process);
> -			free(p->process_ctx);
> -			free(p->socket_ctx);
> +			if (p->process)
> +				free(p->process);
> +			if (p->process_ctx)
> +				free(p->process_ctx);
> +			if (p->socket_ctx)
> +				free(p->socket_ctx);

free(NULL) is a no-op.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
