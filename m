From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPsecv6 integrity failures not dropped
Date: Sat, 19 Apr 2003 20:35:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030419.203543.112604079.davem@redhat.com>
References: <200304182017.h3IKH4ng019821@faith.austin.ibm.com>
	<20030419.115053.123574563.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@wide.ad.jp
In-Reply-To: <20030419.115053.123574563.yoshfuji@wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@wide.ad.jp>
   Date: Sat, 19 Apr 2003 11:50:53 +0900 (JST)

   just change u8 nexthdr = 0 to int nexthdr = 0, in xfrm6_rcv() is fine, 
   isn't it?

That's exactly the most correct fix, applied to my tree.
Thanks.
