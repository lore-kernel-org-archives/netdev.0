From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Don't assign a same IPv6 address on a same
 interface
Date: Mon, 31 Mar 2003 11:05:51 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030331.110551.14104246.davem@redhat.com>
References: <20030330163656.GA18645@ferrara.linux.it>
	<20030331.033524.114862210.yoshfuji@linux-ipv6.org>
	<20030331.103451.118020141.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
   usagi@linux-ipv6.org, pioppo@ferrara.linux.it
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030331.103451.118020141.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Mon, 31 Mar 2003 10:34:51 +0900 (JST)

   In article <20030331.033524.114862210.yoshfuji@linux-ipv6.org> (at Mon, 31 Mar 2003 03:35:24 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
   
   > In article <20030330163656.GA18645@ferrara.linux.it> (at Sun, 30 Mar 2003 18:36:56 +0200), Simone Piunno <pioppo@ferrara.linux.it> says:
   > 
   > >  - locking inside ipv6_add_addr() is simpler and more linear but
   > >    semantically wrong because you're unable to tell the user why his 
   > >    "ip addr add" failed.  E.g. you answer ENOBUFS instead of EEXIST.
   > 
   > We don't want to create duplicate address in any case.
   > ipv6_add_addr() IS right place.
   > And, we can return error code by using IS_ERR() etc.
   > I'll fix this.
   
   Here's the revised patch.

Applied to both 2.4.x and 2.5.x.

BTW, 2.4.x patch failed in two spots, one was author comment
which I easily fixed, second was in privacy code which I did not
apply yet to 2.4.x (I fixed this too, don't worry).

I do not want to put privacy code into 2.4.x until crypto is there.
I plan to put crypto lib into 2.4.22-pre1.
