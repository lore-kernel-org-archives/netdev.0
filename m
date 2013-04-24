From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [net-next PATCH 0/3] Adding phy register fixup in DT
Date: Wed, 24 Apr 2013 14:12:30 +0530
Message-ID: <51779AF6.8060808@ti.com>
References: <1366654838-26479-1-git-send-email-mugunthanvnm@ti.com>
 <20130423080257.GQ32299@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20130423080257.GQ32299-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 4/23/2013 1:32 PM, Sascha Hauer wrote:
> On Mon, Apr 22, 2013 at 11:50:35PM +0530, Mugunthan V N wrote:
>> In earlier days phy fixup was added to phy frame work in board files.
>> As there won't be any board files here after the same has to be done in DT
>> This patch series adds the following features
>> * support for adding phy resigter fixup via DT
>> * adds phy id for EVMsk n DTS file
>> * adds phy fixup for AM335x EVM and EVMsk
>>
>> Mugunthan V N (3):
>>    drivers: of: add phy fixup support in DT
>>    ARM: dts: AM33XX: Add CPSW phy_id device tree data to am335x-evmsk
>>    ARM: dts: AM33XX: add phy fixup for evm and evmsk boards
> I generally do not offend to phy fixups from the devicetree. I see
> though that becomes more and more common that we have to configure
> the tx delays in phys.
>
> The current way seems to be to hardcode register values for each board
> which seems not very flexible and forces us to read phy datasheets
> each time for a new board.
>
> Wouldn't it make more sense to configure the actual delays (in ns) and
> let the phy drivers figure out how to turn this into register values?
>
> Not that I volunteer to write such things... :-/
>
There is no calculation done for enabling RGMII Tx internal delay. Its all
pre-calculated in Hardware (Either in Phy or EMAC)
In this patch as CPSW IP in AM335x doesn't support internal delay inside
SoC, so enabling the same in Phy and it is just a bit set in the phy debug
registers

Regards
Mugunthan V N
