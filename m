From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [patch] bug prematurely setting nr_frags
Date: Mon, 12 Aug 2002 19:07:44 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020812190744.R1781@redhat.com>
References: <20020809161439.E10640@redhat.com> <200208112107.BAA16136@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208112107.BAA16136@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Mon, Aug 12, 2002 at 01:07:33AM +0400
List-Id: netdev.vger.kernel.org

On Mon, Aug 12, 2002 at 01:07:33AM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > that comes from an uninitialized fragment entry in an skb, and this problem 
> > looks like a possible causes.
> 
> This function is not used, by the way.

Huh?  It's called from sock_alloc_send_skb, which is called from all 
over the stack.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."
