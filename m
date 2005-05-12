From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: 2.6.12-rc4-tcp2
Date: Wed, 11 May 2005 21:12:17 -0300
Message-ID: <39e6f6c7050511171244fa6661@mail.gmail.com>
References: <20050511164939.1ec95f2f@dxpl.pdx.osdl.net>
Reply-To: acme@ghostprotocols.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, Baruch Even <baruch@ev-en.org>,
        Daniele Lacamera <mlists@danielinux.net>,
        "Angelo Dell'Aera" <buffer@antifork.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050511164939.1ec95f2f@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 5/11/05, Stephen Hemminger <shemminger@osdl.org> wrote:
> http://developer.osdl.org/shemminger/patches/2.6.12-rc4-tcp2
> 
> Patches that should probably go in 2.6.13.
> Note: Westwood and Hybla need more debugging and don't seem
> to work correctly.
> 
> # stuff to cleanup netif_rx
> fastroute-stats-remove.diff
> no-congestion.diff
> no-throttle.diff
> bigger-backlog.diff
> fix-weightp.diff
> 
> tso-reloaded.patch
> 
> # TCP congestion infrastructure
> tcp_infra.patches

+	/* cleanup private data  (optional) */
+	void (*destory)(struct tcp_sock *tp);
                    ^^^^^
Typo 8)
+	/* return slow satrt threshold (required) */

> tcp_bic.patch
> westwood.patch
> hstcp.patch
> hybla.patch
> vegas.patch
> h-tcp.patch
> 
> # Rearrange sk_buff to make room for bigger cb[]
> # This allows adding ptr for SACK improvement without
> # more memory
> skbuff-del-security.patch
> 
> 


-- 
- Arnaldo
