From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] atmel: Remove open-coded and wrong strcasecmp
Date: Fri, 23 Jan 2015 19:40:23 +0000 (UTC)
Message-ID: <20150123194023.B69BE141EF5@smtp.codeaurora.org>
References: <1421841127-8209-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Simon Kelley <simon@thekelleys.org.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421841127-8209-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The kernel's string library does in fact have strcasecmp, at least
> since ded220bd8f08 ("[STRING]: Move strcasecmp/strncasecmp to
> lib/string.c"). Moreover, this open-coded version is in fact wrong: If
> the strings only differ in their last character, a and b have already
> been incremented to point to the terminating NUL bytes, so they would
> wrongly be treated as equal.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Thanks, applied to wireless-drivers-next.git. I just remove the useless "net:
wireless:" from the title. People, PLEASE stop using that.

Kalle Valo
