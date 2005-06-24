From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch] ipvs: close race conditions on ip_vs_conn_tab list
 modification
Date: Fri, 24 Jun 2005 18:09:40 +0300 (EEST)
Message-ID: <Pine.LNX.4.44.0506241808150.2776-100000__27597.4381751896$1119625786$gmane$org@l>
References: <20050624144822.GD21499@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        Wensong Zhang <wensong@linux-vs.org>, <akpm@osdl.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20050624144822.GD21499@hmsendeavour.rdu.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Fri, 24 Jun 2005, Neil Horman wrote:

>  			if (ct) {
>  				IP_VS_DBG(4, "del conn template\n");
>  				ip_vs_conn_expire_now(ct);
>  			}

	Don't forget to use cp->control instead of ct, ct is not needed
anymore.

Regards

--
Julian Anastasov <ja@ssi.bg>
