From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [RFC 5/7] wlcore: avoid fragile snprintf use
Date: Wed, 09 Mar 2016 13:49:12 +0200
Message-ID: <8760wvswg7.fsf@kamboji.qca.qualcomm.com>
References: <CAGXu5jJ-NApCpANjfz+bAEfwZJ8xizkM-jDHVhOPCzhxV-aqdA@mail.gmail.com>
	<1457469654-17059-1-git-send-email-linux@rasmusvillemoes.dk>
	<1457469654-17059-6-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457469654-17059-6-git-send-email-linux@rasmusvillemoes.dk>
	(Rasmus Villemoes's message of "Tue, 8 Mar 2016 21:40:52 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rasmus Villemoes <linux@rasmusvillemoes.dk> writes:

> Appending to a buffer like this is not guaranteed to work (passing
> overlapping src and dst buffers to snprintf is undefined
> behaviour). The standard and safe idiom is to keep track of the
> current string length.
>
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Should I take this or what's the plan?

-- 
Kalle Valo
