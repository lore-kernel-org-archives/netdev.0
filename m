From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V8 1/7] sxgbe: Add device-tree binding support document
Date: Fri, 21 Mar 2014 07:57:39 -0700
Message-ID: <004c01cf4515$e8ecb350$bac619f0$@samsung.com>
References: <012e01cf4461$79852880$6c8f7980$@samsung.com>
 <20140321110212.GM23372@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'netdev' <netdev@vger.kernel.org>,
	linux-samsung-soc@vger.kernel.org, devicetree@vger.kernel.org,
	'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: 'Mark Rutland' <mark.rutland@arm.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <20140321110212.GM23372@e106331-lin.cambridge.arm.com>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Rutland <mark.rutland@arm.com> wrote:
> > +Example:
> > +
> > +	aliases {
> > +		ethernet0 = <&sxgbe0>;
> > +	};
> > +
> > +	sxgbe0: ethernet@1a040000 {
> > +		compatible = "samsung,sxgbe-v2.0a";
> > +		reg = <0 0x1a040000 0 0x10000>;
> > +		interrupt-parent = <&gic>;
> > +		interrupts = <0 209 4>, <0 185 4>, <0 186 4>, <0 187 4>,
> > +			     <0 188 4>, <0 189 4>, <0 190 4>, <0 191 4>,
> > +			     <0 192 4>, <0 193 4>, <0 194 4>, <0 195 4>,
> > +			     <0 196 4>, <0 197 4>, <0 198 4>, <0 199 4>,
> > +			     <0 200 4>, <0 201 4>, <0 202 4>, <0 203 4>,
> > +			     <0 204 4>, <0 205 4>, <0 206 4>, <0 207 4>,
> > +			     <0 208 4>, <0 210 4>;
> > +		samsung,pbl = <0x08>
> > +		samsung,burst-map = <0x20>
> > +		samsung,adv-addr-mode = "true"
> > +		samsung,force-sf-dma-mode = "true"
> 
> You don't need these strings for boolean properties. Their presence of the
> property alone (even in the absende of a value) is sufficient. These should
> simply be:
> 
> 	samsung,adv-addr-map;
> 	samsung,force-sf-dma-mode;
OK. It looks better

> 
> It is still an open question as to whether these properties are necessary.
I understood, actually those two properties are for future.
"samsung,adv-addr-map" is needed for more than 32 bit addressing and
"force-sf-dma-mode" to use full dma fifo.
As of now these are not mandatory property.
These will be added later, I'll remove it this patch series.

> 
> Cheers,
> Mark.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of
> a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
