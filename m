From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: eliminating magic number for sizeof(struct
 frag_hdr)
Date: Thu, 12 Jun 2003 00:54:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612.005426.118603842.davem@redhat.com>
References: <Pine.LNX.4.44.0306112014560.2321-100000@netcore.fi>
	<20030612.022753.56899094.yoshfuji@linux-ipv6.org>
	<20030612.023919.126807101.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, pekkas@netcore.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030612.023919.126807101.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Thu, 12 Jun 2003 02:39:19 +0900 (JST)

   In article <20030612.022753.56899094.yoshfuji@linux-ipv6.org> (at Thu, 12 Jun 2003 02:27:53 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
   
   > > s/8/sizeof(struct frag_hdr)/ ?
   > 
   > Yes, sizeof(struct frag_hdr). 
   > I, however, use 8 for now to focus on the bug itself.
   > (We have more "8"s there which should be substituted.)
   
   s/8/sizeof(struct frag_hdr)/;
   please apply this on top of the original patch.

I've applied both patches, thanks.
