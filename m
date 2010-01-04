From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] net/ipv4 : Correct the size argument to kzalloc
Date: Mon, 04 Jan 2010 15:23:23 +0100
Message-ID: <4B41F9DB.1010908@trash.net>
References: <Pine.LNX.4.64.0912292016230.4001@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0912292016230.4001@ask.diku.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> obj has type struct snmp_object **, not struct snmp_object *.  But indeed
> it is not even clear why kmalloc is needed.  The memory is freed by the end
> of the function, so the local variable of pointer type should be sufficient.

Thanks. As this is basically just an unneeded and oversized allocation
without any bad consequences, I've applied it to nf-next-2.6.git.


