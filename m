From: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net/macb: add DT support
Date: Mon, 05 Dec 2011 12:51:28 +0100
Message-ID: <4EDCB040.1050305@atmel.com>
References: <20111202153832.GA4998@totoro>
 <1322846050-4543-1-git-send-email-nicolas.ferre@atmel.com>
 <20111202172854.GB4998@totoro> <4ED910B6.7080000@atmel.com>
 <20111205114838.GC21006@totoro>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Jamie Iles <jamie-wmLquQDDieKakBO8gow8eQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20111205114838.GC21006@totoro>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/05/2011 12:48 PM, Jamie Iles :
> On Fri, Dec 02, 2011 at 06:53:58PM +0100, Nicolas Ferre wrote:
>> On 12/02/2011 06:28 PM, Jamie Iles :
> [...]
>>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
>>> index 103c6e6..89060e6 100644
>>> --- a/drivers/net/ethernet/cadence/macb.c
>>> +++ b/drivers/net/ethernet/cadence/macb.c
>>> @@ -1247,6 +1247,8 @@ static const struct of_device_id macb_dt_ids[] = {
>>>   	{ .compatible = "cdns,at32ap7000-macb" },
>>>   	{ .compatible = "cdns,at91sam9260-macb" },
>>>   	{ .compatible = "cdns,macb" },
>>> +	{ .compatible = "cdns,pc302-gem" },
>>> +	{ .compatible = "cdns,gem" },
>>>   	{ /* sentinel */ }
>>>   };
>>
>> BTW, I think we may also modify the MII/RMII selection code for
>> adding gigabit selection... but maybe you already have the patches?
>
> No, I don't have access to a version of the GEM with gigabit support.
> The platforms I was working on used it as a 10/100 controller, but had
> to use the GEM to get hardware timestamping support.

Ok, Thanks for your feedback. I send a v3 patch now.

Best regards,
-- 
Nicolas Ferre
