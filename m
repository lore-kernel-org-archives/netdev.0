From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address
 Autoconfiguration in IPv6
Date: Sun, 23 Feb 2003 22:31:14 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030223.223114.65976206.davem@redhat.com>
References: <20021031.164940.672083668.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0210311021560.19356-100000@netcore.fi>
	<20021101.174832.44646503.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru,
   pekkas@netcore.fi, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021101.174832.44646503.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Fri, 01 Nov 2002 17:48:32 +0900 (JST)

   Ok, here's revised one.
   
    - sync with linux-2.5.45.
    - change default value for use_tempaddr sysctl to 0 
      (don't generate and use temprary addresses by default)
   
It is applied.

Hmmm, some thinking is needed in order to backport this to
2.4.x due to lack of crypto library.  I guess USAGI 2.4.x
version of this patch uses crypto library from USAGI 2.4.x ipsec?
