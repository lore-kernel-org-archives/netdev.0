From: "David S. Miller" <davem@redhat.com>
Subject: Re: net/sctp/sm_make_chunk.c alignment problems on parisc64
Date: Fri, 19 Sep 2003 23:39:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919233909.7ec3aab0.davem@redhat.com>
References: <20030918195525.28c17cb1.davem@redhat.com>
	<Pine.LNX.4.44.0309191440320.4758-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com,
        lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0309191440320.4758-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 19 Sep 2003 15:15:53 -0700 (PDT)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> But unfortunately i am not able see this problem with a parisc64 cross compiler 
> on i386. So it makes it hard to debug or fix it. Looks like this happens only
> when building natively on a parisc64 machine which i don't have access to.

Did you build with or without SMP enabled?

Anyways, try to work with Arnaldo to figure out the precise statement
causing the problems.

> Also while reviewing the code in sctp_pack_cookie(), i noticed a structure
> copy. Are structure copies portable across all the archictectures? Should we
> replace it with a memcpy?

Yes, structure copies are portable.
