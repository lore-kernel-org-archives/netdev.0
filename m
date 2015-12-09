From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 00/14] mm: memcontrol: account socket memory in unified hierarchy v4-RESEND
Date: Wed, 09 Dec 2015 17:31:38 +0100
Message-ID: <2564892.qO1q7YJ6Nb@wuerfel>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449588624-9220-1-git-send-email-hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 December 2015 10:30:10 Johannes Weiner wrote:
> Hi Andrew,
> 
> there was some build breakage in CONFIG_ combinations I hadn't tested
> in the last revision, so here is a fixed-up resend with minimal CC
> list. The only difference to the previous version is a section in
> memcontrol.h, but it accumulates throughout the series and would have
> been a pain to resolve on your end. So here goes. This also includes
> the review tags that Dave and Vlad had sent out in the meantime.
> 
> Difference to the original v4:

I needed two more patches on top of today's linux-next kernel, will
send them as replies to this mail. I don't know if you have already
fixed the issues for !CONFIG_INET and CONFIG_SLOB, if not please
fold them into your series.

	Arnd
