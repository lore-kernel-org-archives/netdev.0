From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] remove all uses of printf's %n
Date: Thu, 19 Sep 2013 21:23:05 -0700
Message-ID: <1379650985.2021.12.camel@joe-AO722>
References: <CAGXu5jL+NeBw2_vXymM81UdtS6UO7KZA2S4rf3gwM_7nSJ2h6g@mail.gmail.com>
	 <20130917205742.16147.qmail@science.horizon.com>
	 <201309191756.BCF65661.MQFOLSJOFHFtOV@I-love.SAKURA.ne.jp>
	 <CAGXu5jK_D1BJOQr=1A-UFrpM5Ad+Qu894HT_XjkZh4EmsbCkTQ@mail.gmail.com>
	 <201309201309.GFB52620.OQOtSFLMJVHOFF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jslaby@suse.cz, viro@zeniv.linux.org.uk, xemul@openvz.org,
	remi.denis-courmont@nokia.com, keescook@chromium.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, linux@horizon.com,
	akpm@linux-foundation.org, dan.carpenter@oracle.com,
	geert@linux-m68k.org, JBeulich@suse.com, kosaki.motohiro@gmail.com
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201309201309.GFB52620.OQOtSFLMJVHOFF@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-09-20 at 13:09 +0900, Tetsuo Handa wrote:
> Hello.

Tetsuo-san:

> We are discussing about removal of %n support from vsnprintf() at
> https://lkml.org/lkml/2013/9/16/52 , and you are using %n in seq_printf().

Well, I'm not using (mere alcohol isn't using, right?)
but I still have the same question for Al.

Are there any races here?

> I posted https://lkml.org/lkml/diff/2013/9/19/53/1 which introduces
> seq_setwidth() / seq_pad() which can avoid use of %n in seq_printf().

I still think adding last_len, last_rtn
is sensible.
