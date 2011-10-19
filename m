From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] Disable TCP_DEBUG and FASTRETRANS_DEBUG by default
Date: Wed, 19 Oct 2011 15:16:00 -0200
Message-ID: <20111019151600.67cd99e6@asterix.rh>
References: <1318883125-29500-1-git-send-email-dpmcgee@gmail.com>
	<20111017.175238.18474279385644215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dpmcgee@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111017.175238.18474279385644215.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Oct 2011 17:52:38 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Dan McGee <dpmcgee@gmail.com>
> Date: Mon, 17 Oct 2011 15:25:24 -0500
> 
> > If these are truly debug options, they should be turned off by default
> > and can be tweaked if necessary. Fix one usage of the flag to use #if
> > instead of #ifdef so defining to zero is acceptable.
> > 
> > Signed-off-by: Dan McGee <dpmcgee@gmail.com>
> 
> Illegal window shrinks are a serious issue, and the fact that everyone
> will see those messages by default and sometimes report them has been
> tremendously useful.
>

Agreed. I recently got bug report because of that message.  It is useful
and doesn't disturbe when network is fine, so please don't remove it.

fbl
