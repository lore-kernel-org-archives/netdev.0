From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system for Linux (LibOS)
Date: Fri, 27 Mar 2015 14:01:22 +1030
Message-ID: <87iodnqfp1.fsf@rustcorp.com.au>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp> <551164ED.5000907@nod.at> <m2twxacw13.wl@sfc.wide.ad.jp> <55117565.6080002@nod.at> <m2sicuctb2.wl@sfc.wide.ad.jp> <55118277.5070909@nod.at> <m2bnjhcevt.wl@sfc.wide.ad.jp> <55133BAF.30301@nod.at> <m2h9t7bubh.wl@wide.ad.jp> <5514560A.7040707@nod.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com,
	mathieu.lacage@gmail.com
To: Richard Weinberger <richard@nod.at>,
	Hajime Tazaki <tazaki@wide.ad.jp>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <5514560A.7040707@nod.at>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Weinberger <richard@nod.at> writes:
> This also infers that arch/lib will be broken most of the time as
> every time the networking stack references a new symbol it
> has to be duplicated into arch/lib.
>
> But this does not mean that your idea is bad, all I want to say that
> I'm not sure whether arch/lib is the right approach.
> Maybe Arnd has a better idea.

Exactly why I look forward to getting this in-tree.  Jeremy Kerr and I
wrote nfsim back in 2005(!) which stubbed around the netfilter
infrastructure; with failtest and valgrind it found some nasty bugs.  It
was too much hassle to maintain out-of-tree though :(

I look forward to a flood of great bugfixes from this work :)

Cheers,
Rusty.
