From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 2/6] net: ethernet: ti: cpts: add support for ext rftclk
 selection
Date: Tue, 6 Dec 2016 14:40:48 -0600
Message-ID: <1f0c1579-7b9a-49a4-c3b4-79c40051b9fd@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-3-grygorii.strashko@ti.com>
 <20161130095632.GC28680@localhost.localdomain>
 <bf207ac4-0f9f-d4a7-14ac-704d93fb7764@ti.com>
 <11994fbc-3713-6ef7-8a44-8a2442106dfc@ti.com>
 <20161206202558.GB23605@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161206202558.GB23605-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 12/06/2016 02:25 PM, Richard Cochran wrote:
> On Tue, Dec 06, 2016 at 01:39:40PM -0600, Grygorii Strashko wrote:
>> I come with below RFC patch. if no objection I'll move forward with it.
> 
> Thanks for following through with this!
> 
> The am335x will also need the MUX in its clock tree, won't it?
> 

Not exactly. I do not see CPTS_RFTCLK_SEL register in trm, but looks like
it's already implemented in am335 clock tree:
	cpsw_cpts_rft_clk: cpsw_cpts_rft_clk@520 {
		#clock-cells = <0>;
		compatible = "ti,mux-clock";
		clocks = <&dpll_core_m5_ck>, <&dpll_core_m4_ck>;
		reg = <0x0520>;
	};

and ssigned-clock-xx can be used to change parent in board file:

&cpsw_cpts_rft_clk {
assigned-clocks = <&cpsw_cpts_rft_clk>;
assigned-clock-parents = <&dpll_core_m4_ck>;
};


-- 
regards,
-grygorii
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
