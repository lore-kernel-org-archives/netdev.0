From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] tcp: sysctl to disable TCP simultaneous connect
Date: Thu, 07 Feb 2013 11:29:08 -0800
Message-ID: <51140084.3080902@zytor.com>
References: <20130207175240.GA12520@www.outflux.net> <20130207103950.662698ea@nehalam.linuxnetplumber.net> <CAGXu5jJiupzommJYPEYQnk-4i9FUKai0NcPnihLN-QpWV64jtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
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
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jJiupzommJYPEYQnk-4i9FUKai0NcPnihLN-QpWV64jtQ@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/2013 10:44 AM, Kees Cook wrote:
>>
>> This patch probably also breaks TCP STUNT that is used by some applications for NAT
>> traversal.
> 
> The patch would not break it -- it defaults the sysctl to staying enabled.
> 
> If you mean the documentation should be updated, sure, that's easy to do.
> 
> David: I know you aren't a fan of this patch, but I'd like to try to
> convince you. :) This leaves the feature enabled and add a toggle for
> systems (like Chrome OS) that don't want to risk this DoS at all.
> There are so very many other toggle, I don't see why this one would be
> a problem to add.
> 

It is not just STUNT, but in NAT-less configurations behind stateful
firewalls (which is expected to be the norm for IPv6), TCP rendezvous
via crossed SYN is a very effective way to establish peer-to-peer
connections.

	-hpa

