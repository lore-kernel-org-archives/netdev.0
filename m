From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] remove all uses of printf's %n
Date: Fri, 20 Sep 2013 12:33:16 -0700
Message-ID: <1379705596.2301.17.camel@joe-AO722>
References: <CAGXu5jL+NeBw2_vXymM81UdtS6UO7KZA2S4rf3gwM_7nSJ2h6g@mail.gmail.com>
	 <20130917205742.16147.qmail@science.horizon.com>
	 <201309191756.BCF65661.MQFOLSJOFHFtOV@I-love.SAKURA.ne.jp>
	 <CAGXu5jK_D1BJOQr=1A-UFrpM5Ad+Qu894HT_XjkZh4EmsbCkTQ@mail.gmail.com>
	 <201309201309.GFB52620.OQOtSFLMJVHOFF@I-love.SAKURA.ne.jp>
	 <523C0268.20404@suse.cz>
	 <CAGXu5jLENb+x6b9XOY7-pWMT7GsFgnLr0=A8VNFLkqMi0BX4=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jslaby@suse.cz>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Pavel Emelyanov <xemul@openvz.org>,
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, George Spelvin <linux@horizon.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Jan Beulich <JBeulich@suse.com>,
	Motohiro KOSAKI <kosaki.motohiro@gmail.com>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jLENb+x6b9XOY7-pWMT7GsFgnLr0=A8VNFLkqMi0BX4=w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-09-20 at 12:24 -0700, Kees Cook wrote:
> There are a few problems that have been discussed on the various
> threads. Namely, we want to minimize the changes to the seq_file
> structure and to not add additional work to all the seq_file users
> that don't care about padding.

I don't think saving a couple more values to a struct
is that big a deal.
