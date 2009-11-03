From: "=?ISO-8859-15?Q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.32-rc5-mmotm1101 - kernel BUG at net/ipv4/tcp_input.c:3707!
Date: Tue, 3 Nov 2009 23:34:19 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0911032330090.3488@melkinkari.cs.Helsinki.FI>
References: <5765.1257270611@turing-police.cc.vt.edu> <4AF07024.80103@gmail.com>
 <4AF08292.7090102@codefidence.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243445-11042555-1257283974=:3488"
Cc: Valdis.Kletnieks@vt.edu, Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ori Finkelman <ori@comsleep.com>
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755326AbZKCVeR@vger.kernel.org>
In-Reply-To: <4AF08292.7090102@codefidence.com>
Content-ID: <Pine.LNX.4.64.0911032333060.3488@melkinkari.cs.Helsinki.FI>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243445-11042555-1257283974=:3488
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0911032333061.3488@melkinkari.cs.Helsinki.FI>

On Tue, 3 Nov 2009, Gilad Ben-Yossef wrote:

> Eric Dumazet wrote:
> 
> > Valdis.Kletnieks@vt.edu a écrit :
> >   
> > > Seen right after I started 'fetchmail'.  Reproducible - 3 out of 3.
> > > I'll bisect this tonight if nobody jumps up and yells they know what it
> > > is...
> > >     
> Bah... this is most probably my fault. Sorry about that.
> 
> Can you please try the patch in the next email?
> 
> But also, can you please send me the route table in effect when this happened
> and the fetchmail command line/config (removing any passwords or account
> details of course)? I want to understand better when this happens.

According to the stacktrace, it came from ipv6 side which doesn't have any 
null checking what so ever atm (you only handled ipv4 correctly). ...You 
should be a bit more careful next time when adding any BUG_ONs...

-- 
 i.
---696243445-11042555-1257283974=:3488--
