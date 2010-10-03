From: Willy Tarreau <w@1wt.eu>
Subject: Re: sysctl_{tcp,udp,sctp}_mem overflow on 16TB system.
Date: Sun, 3 Oct 2010 18:43:24 +0200
Message-ID: <20101003164324.GC3711@1wt.eu>
References: <20101001193958.GP14068@sgi.com> <20101001203022.GA28486@1wt.eu> <AANLkTin5wPvFQDFrupqGs_Jbh1rgrTjMupbPUFnvrBrv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robin Holt <holt@sgi.com>, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, linux-sctp@vger.kernel.org
To: Maciej ??enczykowski <zenczykowski@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTin5wPvFQDFrupqGs_Jbh1rgrTjMupbPUFnvrBrv@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 03, 2010 at 01:20:32AM -0700, Maciej ??enczykowski wrote:
> Isn't INT_MAX/2 just 1GB, which is only ~0.9 seconds at 10 Gbps?

no, the size is in pages (and is often wrong when people change it
from the default value).

Regards,
Willy
