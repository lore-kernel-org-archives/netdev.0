From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch]: ipv6 tunnel for MIPv6
Date: Tue, 03 Jun 2003 21:34:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603.213458.112594590.davem@redhat.com>
References: <Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi>
	<Pine.LNX.4.44.0305301735340.3584-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
   ajtuomin@morphine.tml.hut.fi, lpetande@morphine.tml.hut.fi,
   jagana@us.ibm.com, kumarkr@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0305301735340.3584-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ville Nuorvala <vnuorval@tcs.hut.fi>
   Date: Fri, 30 May 2003 18:00:55 +0300 (EEST)

   The patch is sent as an attachment to this mail, but is also available at:
   
You need to fix some things before I will apply this:

1) Bogus #ifdef CONFIG_IPV6_TUNNEL_MODULE.  You need not this test
   around things like MODULE_AUTHOR() and stuff like that,
   linux/module.h does that for you.

2) Dependency upon subtrees patch, please remove it.  There is no
   agreement on that semantic change to how subtrees work.

Thanks.
