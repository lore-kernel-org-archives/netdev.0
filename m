From: "David S. Miller" <davem@redhat.com>
Subject: Re: is sk->reuse truly a boolean?
Date: Thu, 22 May 2003 00:01:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522.000154.68050329.davem@redhat.com>
References: <20030521.015317.125867074.yoshfuji@linux-ipv6.org>
	<20030520165831.GG801@conectiva.com.br>
	<20030521.020242.16237776.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030521.020242.16237776.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Wed, 21 May 2003 02:02:42 +0900 (JST)

   In article <20030520165831.GG801@conectiva.com.br> (at Tue, 20 May 2003 13:58:31 -0300), Arnaldo Carvalho de Melo <acme@conectiva.com.br> says:
   
   > So just delete the test?
   
   Hmm, (bacause I want to remember this path in the code,) how about #if 0 ?
   David?

You may #if 0 this as long as you:

1) Add comment.
2) Add identical code block to tcp_ipv6.c
