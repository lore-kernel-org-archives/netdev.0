From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: inappropriate static variable in net/ipv6/ndisc.c
Date: Wed, 25 Jun 2003 22:23:42 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625.222342.48531169.davem@redhat.com>
References: <20030626.142109.76202395.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030626.142109.76202395.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Thu, 26 Jun 2003 14:21:09 +0900 (JST)

   It is not appropriate to use static variable here.
   
It used to be actually needed when ipv6 flows contained
pointers to addresses, and yes that was racey.
   
I'll apply this, thanks.
