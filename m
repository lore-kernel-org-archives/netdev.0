From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: nfsd oops with 2.6.5-rc2-mm4
Date: Sun, 28 Mar 2004 18:44:29 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403281840011.1096@ppc970.osdl.org>
References: <20040327130757.GA6760@c9x.org>  <Pine.LNX.4.58.0403271816450.20100@ppc970.osdl.org>
 <1080511633.5553.29.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David S Miller <davem@redhat.com>, Neil Brown <neilb@cse.unsw.edu.au>,
        Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>, Frank Denis <jedi@orbus.fr>
In-Reply-To: <1080511633.5553.29.camel@lade.trondhjem.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sun, 28 Mar 2004, Trond Myklebust wrote:
> 
> I'm not really that familiar with Neil's code, but looking at
> encode_entry(), shouldn't it test for the buffer overflow condition
> whereby pn >= cd->rqstp->rq_resused, and exit if it does? Neil?

Ok, I took Neils patch, which touches the same function, but looks very 
different.

Frank, can you test the current top-of-BK tree (or if not a BK user, try
the snapshot tomorrow that should get build at 2AM tonight). It would be 
good to get this thing confirmed.

		Linus
