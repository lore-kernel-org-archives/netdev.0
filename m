From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch]: ipv6 tunnel for MIPv6
Date: Sat, 07 Jun 2003 03:30:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030607.033059.48393210.davem@redhat.com>
References: <20030603.213458.112594590.davem@redhat.com>
	<Pine.LNX.4.44.0306041454460.26066-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
   ajtuomin@morphine.tml.hut.fi, lpetande@morphine.tml.hut.fi,
   jagana@us.ibm.com, kumarkr@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0306041454460.26066-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ville Nuorvala <vnuorval@tcs.hut.fi>
   Date: Wed, 4 Jun 2003 15:40:02 +0300 (EEST)
   
   The revised version is attached to this mail,

Looks ok, but sorry two things need to be fixed up first:

1) Doesn't apply anymore, I think it's because of the
   struct sock member renames, just replace sk->foo
   with sk->sk_foo

2) Just export all those routines from net/ipv6/ipv6_syms.c
   always, remove the ifdefs.

I promise to apply it after you fix this stuff up :)))

Thank you.
