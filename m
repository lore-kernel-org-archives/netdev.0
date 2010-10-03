From: Robin Holt <holt@sgi.com>
Subject: Re: sysctl_{tcp,udp,sctp}_mem overflow on 16TB system.
Date: Sun, 3 Oct 2010 06:54:19 -0500
Message-ID: <20101003115419.GQ14068@sgi.com>
References: <20101001193958.GP14068@sgi.com>
 <20101001203022.GA28486@1wt.eu>
 <AANLkTin5wPvFQDFrupqGs_Jbh1rgrTjMupbPUFnvrBrv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>, Robin Holt <holt@sgi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, linux-sctp@vger.kernel.org
To: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:50705 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872Ab0JCLyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Oct 2010 07:54:24 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTin5wPvFQDFrupqGs_Jbh1rgrTjMupbPUFnvrBrv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 03, 2010 at 01:20:32AM -0700, Maciej =C5=BBenczykowski wrot=
e:
> Isn't INT_MAX/2 just 1GB, which is only ~0.9 seconds at 10 Gbps?

Units matter.  1GB pages.  We can limit to 2GB pages or 8TB.

Robin
