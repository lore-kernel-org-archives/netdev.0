From: David Howells <dhowells@redhat.com>
Subject: Re: [guv v2 04/31] net: Replace __get_cpu_var uses
Date: Tue, 03 Sep 2013 21:39:28 +0100
Message-ID: <7928.1378240768@warthog.procyon.org.uk>
References: <20130902.203355.117341085023152754.davem@davemloft.net> <00000140bc5ef9df-d7f75909-a25e-4471-84b2-dfbec07117b0-000000@email.amazonses.com> <20130826204351.725357339@linux.com> <7435.1378157706@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, cl@linux.com, tj@kernel.org,
	akpm@linuxfoundation.org, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org, srostedt@redhat.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130902.203355.117341085023152754.davem@davemloft.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> > Would it be possible to use __thread annotations for per-CPU
> > variables, I wonder?
> 
> Paul Mackerras tried it on powerpc and you can't do it.
> 
> The problem is that there is no way to tell the compiler that sched()
> and similar (potentially) change the thread pointer base.
> 
> It really will cache pre-computed __thread pointer calculations across
> sched().

Yeah...  I thought there might be something like that - but I could see x86_64
using %fs as a base.

David
