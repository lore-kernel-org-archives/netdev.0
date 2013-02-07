From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: sysctl to disable TCP simultaneous connect
Date: Thu, 07 Feb 2013 14:29:11 -0500 (EST)
Message-ID: <20130207.142911.101451648518406435.davem@davemloft.net>
References: <20130207175240.GA12520@www.outflux.net>
	<20130207103950.662698ea@nehalam.linuxnetplumber.net>
	<CAGXu5jJiupzommJYPEYQnk-4i9FUKai0NcPnihLN-QpWV64jtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, linux-kernel@vger.kernel.org,
	rob@landley.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, edumazet@google.com,
	nhorman@tuxdriver.com, ycheng@google.com, davidshan@tencent.com,
	linux-doc@vger.kernel.org, netdev@vger.kernel.org, w@1wt.eu
To: keescook@chromium.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jJiupzommJYPEYQnk-4i9FUKai0NcPnihLN-QpWV64jtQ@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Thu, 7 Feb 2013 10:44:02 -0800

> David: I know you aren't a fan of this patch, but I'd like to try to
> convince you. :) This leaves the feature enabled and add a toggle for
> systems (like Chrome OS) that don't want to risk this DoS at all.
> There are so very many other toggle, I don't see why this one would be
> a problem to add.

We're not in the business of allowing the changing of the TCP state
machine behavior like this.  Sorry.
