From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Fri, 27 Sep 2002 18:28:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927.182833.66704359.davem@redhat.com>
References: <20020928.001742.125874265.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org,
   kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20020928.001742.125874265.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Sat, 28 Sep 2002 00:17:42 +0900 (JST)

Please redesign this structure.

   +struct addrselect_attrs {
   +	struct inet6_ifaddr *ifp;
   +	int	match;
   +	int	deprecated;
   +	int	home;
   +	int	temporary;
   +	int	device;
   +	int	scope;
   +	int	label;
   +	int	matchlen;
   +};

This is much larger than it needs to be.  Please replace these "int"
binary states with single "u32 flags;" and appropriate bit
definitions.

This structure sits on the stack, so it is important to be
as small as we can easily make it.

Otherwise I have no problems with the patch, Alexey?
