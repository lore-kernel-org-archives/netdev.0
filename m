From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] USAGI IPsec
Date: Fri, 11 Oct 2002 19:41:08 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021011.194108.102576152.davem@redhat.com>
References: <m3u1js1l1a.wl@karaba.org>
	<20021011.185332.115906289.davem@redhat.com>
	<20021012.114330.78212112.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: mk@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021012.114330.78212112.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Sat, 12 Oct 2002 11:43:30 +0900 (JST)
   
   Would you tell us the points of the "several details," please?

We believe that the whole SPD/SAD mechanism should move
eventually to a top-level flow cache shared by ipv4 and
ipv6.

Therefore all the interfaces will be architected such that
a move to a flow cache based lookup system will be a very
simple change.
