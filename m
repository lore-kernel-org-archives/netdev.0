From: Stefan Roese <mail@roese.nl>
Subject: Re: socfpga/sockit ethernet problems
Date: Tue, 08 Jul 2014 09:47:37 +0200
Message-ID: <53BBA219.8000607@roese.nl>
References: <20140507104518.GB18139@amd.pavel.ucw.cz>
 <20140703093548.GA9937@amd.pavel.ucw.cz>
 <1404764751.14294.3.camel@linux-builds1>
 <20140707214340.GA29061@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: dzu@denx.de, netdev@vger.kernel.org, gsi@denx.de, peppe.cavallaro@st.com,
 s.trumtrar@pengutronix.de, linux-arm-kernel@lists.infradead.org
To: Pavel Machek <pavel@denx.de>, Dinh Nguyen <dinguyen@altera.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20140707214340.GA29061@amd.pavel.ucw.cz>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi!

On 07.07.2014 23:43, Pavel Machek wrote:
>> All of this stuff is not needed as it's already taken care of by the
>> Micrel phy driver. The clock skew values are now represented in the DTS.
>> Please look at:
>>
>> Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
>
> Aah, thanks for the pointer.
>
> At least socfpga_cyclone5_socrates.dts is in the mainline, but it does
> not have any skew configuration. That may explain why the board seems
> to have problems with ethernet... (or not).
>
> Are there suitable default values?
>
> u-boot uses these defaults:
>
> include/configs/socfpga_common.h:#define CONFIG_KSZ9021_CLK_SKEW_VAL
> 0xf0f0
> include/configs/socfpga_common.h:#define CONFIG_KSZ9021_DATA_SKEW_VAL
> 0x0
>
> ...that should correspond to txc-skew-ps == rxc-skew-ps == 3000, all
> other skew values == 0?
>
> Could someone with socrates board and network problems test if this
> makes any difference?

SoCrates uses a different PHY, the Lantiq PEF7071 (PHY11G). So those dts 
additions have no effect on SoCrates.

Thanks,
Stefan
