From: wwguy <wey-yi.w.guy@intel.com>
Subject: Re: iwlagn regression in v3.1.5
Date: Tue, 13 Dec 2011 15:20:17 -0800
Message-ID: <1323818417.21617.0.camel@wwguy-ubuntu>
References: <4EE4AEF4.2080702@udo.edu>	<4EE4DB55.4090804@udo.edu>
	 <20111211174138.79e51fe8@x220.fritz.box>	<4EE4E152.2070204@udo.edu>
	 <1323627815.1806.19.camel@wwguy-ubuntu>	<4EE50266.4050208@udo.edu>
	 <1323653737.1806.21.camel@wwguy-ubuntu>	<4EE636B9.1020305@udo.edu>
	 <1323807327.7144.6.camel@wwguy-ubuntu>	<4EE7BEC1.1060506@udo.edu>
	 <20111213230443.2c12caeb@x220.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrej Gelenberg <andrej.gelenberg@udo.edu>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Udo Steinberg <udo@hypervisor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111213230443.2c12caeb@x220.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-12-13 at 14:04 -0800, Udo Steinberg wrote:
> Hi,
> 
> Glad to hear it works for you now. In the patch, the following piece of code
> 
> +				if ((iwl_is_associated_ctx(ctx) &&
> +						!ctx->ht.is_40mhz) ||
> +						!iwl_is_associated_ctx(ctx))
> 
> can be simplified to:
> 
> 	if (!iwl_is_associated_ctx(ctx) || !ctx->ht.is_40mhz)
> 
right, looks better this way :-)

Thanks
Wey
