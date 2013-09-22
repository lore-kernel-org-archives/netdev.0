From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 1/2] remove all uses of printf's %n
Date: 22 Sep 2013 04:09:59 -0400
Message-ID: <20130922080959.384.qmail@science.horizon.com>
References: <201309210928.JCF90671.OtOFLFQSOJVFMH@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, dan.carpenter@oracle.com,
	geert@linux-m68k.org, JBeulich@suse.com, joe@perches.com,
	kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org,
	linux-sctp@vger.kernel.org, linux@horizon.com,
	netdev@vger.kernel.org, remi.denis-courmont@nokia.com,
	viro@zeniv.linux.org.uk, xemul@openvz.org
To: jslaby@suse.cz, keescook@chromium.org,
	penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201309210928.JCF90671.OtOFLFQSOJVFMH@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If you want, we can rename seq_pad() to seq_pad_and_putc(). Also we can pass
> both the padding character (e.g. ' ') and the trailing character (e.g. '\n')
> like seq_pad_and_putc((' ' << 8) | '\n'), though I wonder someone wants to
> use '\0', '\t', '\n' etc. as the padding character...

How about let that complexity wait until it's needed?  It's not like
it's that big a PITA of a patch to write, and there's a significant
chance it will *never* be needed.
