From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] tcp: sysctl to disable TCP simultaneous connect
Date: Thu, 14 Feb 2013 21:30:41 -0800
Message-ID: <87y5eq87pa.fsf@xmission.com>
References: <20130207175240.GA12520@www.outflux.net>
	<20130207103950.662698ea@nehalam.linuxnetplumber.net>
	<CAGXu5jJiupzommJYPEYQnk-4i9FUKai0NcPnihLN-QpWV64jtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Rob Landley <rob@landley.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Yuchung Cheng <ycheng@google.com>,
	Shan Wei <davidshan@tencent.com>,
	"linux-doc\@vger.kernel.org" <linux-doc@vger.kernel.org>,
	netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jJiupzommJYPEYQnk-4i9FUKai0NcPnihLN-QpWV64jtQ@mail.gmail.com>
	(Kees Cook's message of "Thu, 7 Feb 2013 10:44:02 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook@chromium.org> writes:

> The patch would not break it -- it defaults the sysctl to staying enabled.
>
> If you mean the documentation should be updated, sure, that's easy to do.
>
> David: I know you aren't a fan of this patch, but I'd like to try to
> convince you. :) This leaves the feature enabled and add a toggle for
> systems (like Chrome OS) that don't want to risk this DoS at all.
> There are so very many other toggle, I don't see why this one would be
> a problem to add.

Chrome OS has no plans to implement webrtc?  Last I had read that
support had been added to the release versions of Chrome, and was in the
development builds of firefox.  I really don't belive that there are
many systems that don't intend to run a web browser.

Eric
