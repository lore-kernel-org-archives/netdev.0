From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [2.6 PATCH] Fix IPVS sync state check
Date: Tue, 14 Oct 2003 00:29:10 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310140016290.1138-100000@u.domain.uli>
References: <20031013122540.0446f173.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Wensong Zhang <wensong@linux-vs.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031013122540.0446f173.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 13 Oct 2003, David S. Miller wrote:

> BTW, on the 2.4.x side the IPVS code still has the NF_DROP return
> which Julian changed in the 2.6.x version of the IPVS code.  Maybe
> this 2.6.x NF_DROP change needs to be propagated into the 2.4.x code?

	The current 2.4 code does not need such fix, it was a
2.6 specific bug that I introduced with the non-linear patch.

Regards

--
Julian Anastasov <ja@ssi.bg>
