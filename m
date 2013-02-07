From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] tcp: sysctl to disable TCP simultaneous connect
Date: Thu, 7 Feb 2013 10:39:50 -0800
Message-ID: <20130207103950.662698ea@nehalam.linuxnetplumber.net>
References: <20130207175240.GA12520@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Rob Landley <rob@landley.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Yuchung Cheng <ycheng@google.com>,
	Shan Wei <davidshan@tencent.com>, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130207175240.GA12520@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Feb 2013 09:52:40 -0800
Kees Cook <keescook@chromium.org> wrote:

> This is based on Willy Tarreau's patch from 2008[1]. The goal is to
> close a corner-case of TCP that isn't used and poses a small DoS risk.
> For systems that do not want to take any risk at all, this is a desirable
> configuration knob.
> 
> It is possible for two clients to connect with crossed SYNs without
> checking sequence numbers. As such, it might be possible to guess a source
> port number to block a system from making connections to well-known
> ports and IP addresses (e.g. auto-update checks) without requiring a
> MiTM position.
>

This patch probably also breaks TCP STUNT that is used by some applications for NAT
traversal.
