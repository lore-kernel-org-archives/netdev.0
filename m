From: Andi Kleen <ak@suse.de>
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 14:54:52 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <acdg7j$eg7$2@main.gmane.org>
References: <Pine.LNX.4.33.0205201836160.9301-100000@w-nivedita2.des.beaverton.ibm.com> <3CE9E466.AC2358EE@mvista.com> <20020520.230021.29510217.davem@redhat.com> <3CE9F679.90ACF597@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, niv@us.ibm.com, kuznet@ms2.inr.ac.ru,
   ak@suse.de, netdev@oss.sgi.com, linux-net@vger.kernel.org, ak@muc.de,
   pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george anzinger <george@mvista.com>
Content-Disposition: inline
In-Reply-To: <3CE9F679.90ACF597@mvista.com>
List-Id: netdev.vger.kernel.org

> As for the fix, I would think that would be more up to the
> network folks than me.  Atomic is one option, but you can
> also disable preemption.  It is really light weight, and may
> already be disabled in some of these cases.

In most of them because it is running in a softirq.
Just the user context stuff has a possible problem on non i386/x86-64.

-Andi
