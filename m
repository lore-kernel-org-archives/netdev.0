From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch]: ipv6 tunnel for MIPv6
Date: Tue, 03 Jun 2003 21:38:30 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603.213830.85382657.davem@redhat.com>
References: <Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi>
	<Pine.LNX.4.44.0305301735340.3584-200000@rhea.tcs.hut.fi>
	<20030531.003858.108351451.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   ajtuomin@morphine.tml.hut.fi, lpetande@morphine.tml.hut.fi,
   jagana@us.ibm.com, kumarkr@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030531.003858.108351451.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Sat, 31 May 2003 00:38:58 +0900 (JST)

   In article <Pine.LNX.4.44.0305301735340.3584-200000@rhea.tcs.hut.fi> (at Fri, 30 May 2003 18:00:55 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
   > The tunnels are needed by MIPv6 for encapsulation and decapsulation of
   > tunneled packets between the home agent and mobile node. Some proctocols
   > like DHCP are also run over the virtual link between the MN and the home
   > network according to the MIPv6 specification.
   
   I'm not sure if MIP6 will use this tunnel driver.

Yes, it is an important issue.

I am VERY UPSET that there appears to be NO dialogue between USAGI and
MIPV6 folks to discuss design of MIPV6.  If you do not talk together,
how can you guys possibly coordinate efforts and not avoid duplicated
work?

And, it is very clear from my perspective that it is the MIPV6
developers who are not communicating.  USAGI are making an effort
to discuss the issues, but MIPV6 coders disappear for weeks at a time
not answering queries made to them or comments made about their
patch submissions.

That is unacceptable.  And this makes me less likely to apply any
patches from MIPV6 project, here is why.  If some bug shows in some
patch I apply from MIPV6 project, can I expect them to act similarly
and not respond for weeks at a time?  That's intolerable.  If you add
some bug to the tree, you are responsible to be responsive and fix
the problem in a reasonable amount of time.
