From: Henrik Petander <lpetande@tml.hut.fi>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Fri, 06 Jun 2003 14:14:35 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE0779B.9080300@tml.hut.fi>
References: <20030424132559.GA15894@morphine.tml.hut.fi>	<Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi>	<20030531.000319.114704530.yoshfuji@linux-ipv6.org>	<20030605.191224.68706097.yoshfuji@linux-ipv6.org> <20030606143844.0604c306.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
 <yoshfuji@linux-ipv6.org>,
   vnuorval@tcs.hut.fi, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi,
   lpetande@morphine.tml.hut.fi, jagana@us.ibm.com, kumarkr@us.ibm.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <20030606143844.0604c306.nakam@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Nakamura,

Masahide NAKAMURA wrote:
> Hello,
> I'm Nakamura, a member of USAGI.
> 
>
> As you know, we've been planning the MIPv6 design to use XFRM.
> If we use MIPv6, we need some fix and extension to XFRM and it results to make XFRM
> more generic.

I like your idea, as it allows a high level of flexibility in use of
mipv6  with flows through the definition of policies. This is the way I
would also do mipv6 extension header addition with xfrm.

However, if you insert mipv6 policies into xfrm, you need to take care
of the interactions between ipsec and mipv6 policies. The system needs
to cope with data flows to which both ipsec and mipv6 should be applied.
As a result of this the logic of the xfrm lookups probably needs some
changes to return both the matching ipsec and mipv6 policies. How have
you planned to solve this problem?

BTW, feel free to use relevant parts of my code for the output
functionality to speed up the work. After your code is ready we can look
at which approach is better suited for implementing the kernel support
and get a working kernel infrastructure for mipv6 into 2.6 kernels.

Henrik
