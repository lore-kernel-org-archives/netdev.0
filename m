From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [patch] bug prematurely setting nr_frags
Date: Tue, 13 Aug 2002 14:31:20 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020813143120.C12730@redhat.com>
References: <20020812190744.R1781@redhat.com> <200208130406.IAA20038@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208130406.IAA20038@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Tue, Aug 13, 2002 at 08:06:13AM +0400
List-Id: netdev.vger.kernel.org

On Tue, Aug 13, 2002 at 08:06:13AM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > Huh?  It's called from sock_alloc_send_skb, which is called from all 
> > over the stack.
> 
> It is used with data_len==0. The branch generating fragments is dead.

Ah, I see.  Care for a patch to remove it altogether then?  As for the 
bug, does anyone else see a place where nr_frags can be set without 
initializing a page pointer?  Otherwise it looks like a random memory 
corruption... what fun.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."
