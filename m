From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same Port
Date: Thu, 03 Oct 2002 07:10:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003.071058.89246593.davem@redhat.com>
References: <20021003.121350.119660876.yoshfuji@linux-ipv6.org>
	<200210031301.RAA29267@sex.inr.ac.ru>
	<20021003.231534.83777766.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021003.231534.83777766.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Thu, 03 Oct 2002 23:15:34 +0900 (JST)

   In article <200210031301.RAA29267@sex.inr.ac.ru> (at Thu, 3 Oct 2002 17:01:11 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:
   
   > What's about the problem, it cannot be a problem for TCP, connection
   > uniqueness is verified by tcp_*_check_established() not depending
   > on value of SO_REUSEADDR. What's about UDP, the problem really might
   > be a real problem, let's defer the issue, it looks absoluteky unrelated.
   
   Hmm, but I'm afraid that different behavior between TCP and UDP would
   confuse users.
   
He is saying we should do the TCP part first to make the patch simpler
and easier to verify.

Then we can investigate the UDP side seperately.
   
   > BTW the question: why is bindv6only in device configuration directory?
   
   Because I thought that net.ipv6.conf is the place for all 
   configuration...

It is for interface level configuration.
   
   Do you propose to move it to parent directory (net.ipv6.bindv6only),
   and put other general settings there?
   
Yes.
