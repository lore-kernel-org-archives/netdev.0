From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] drivers: net: wireless: Add include guards
Date: Fri, 22 Aug 2014 15:32:58 +0200
Message-ID: <87egw8sl85.fsf@rasmusvillemoes.dk>
References: <1408710414-13810-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408710414-13810-1-git-send-email-linux@rasmusvillemoes.dk>
	(Rasmus Villemoes's message of "Fri, 22 Aug 2014 14:26:54 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rasmus Villemoes <linux@rasmusvillemoes.dk> writes:

> The files ray_cs.h and rayctl.h both contain two thirds of what
> appears to be an include guard using the macro name RAYLINK_H (both
> lack the #define). Since RAYLINK_H is not defined anywhere, the
> guards using different macro names.
>

I need to stop using the # character in my commit messages, or at least
check that git didn't eat any of my lines.

This was supposed to be something like "... defined anywhere, the
#ifndefs are simply confusing no-ops. Add proper include guards using
different macro names".

Rasmus
