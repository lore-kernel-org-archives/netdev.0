From: "David S. Miller" <davem@redhat.com>
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Thu, 14 Nov 2002 08:51:09 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021114.085109.06389530.davem@redhat.com>
References: <20021113085517.GA9134@outpost.ds9a.nl>
	<200211132046.XAA12943@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200211132046.XAA12943@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Wed, 13 Nov 2002 23:46:40 +0300 (MSK)

   Log message for Dave:
   
   - xfrm_state.c: never return mature SAs on getspi.
   - af_key.c: do not forget to delete dummy super-larvals when they are resolved
   - af_key.c: wow! specially for this case I added gfp argument
               to xfrm_alloc_policy() and forgot to use it really.

Applied, thanks.
