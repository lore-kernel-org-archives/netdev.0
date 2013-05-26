From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [net-next PATCH v2 1/6] net: cpsw: enhance pinctrl support
Date: Sun, 26 May 2013 12:49:14 +0530
Message-ID: <51A1B772.4070201@ti.com>
References: <1369312228-3308-1-git-send-email-mugunthanvnm@ti.com>
 <1369312228-3308-2-git-send-email-mugunthanvnm@ti.com>
 <20130525.234248.683332656832128763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 gururaja.hebbar-l0cyMroinI0@public.gmane.org, benoit.cousson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20130525.234248.683332656832128763.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On 5/26/2013 12:12 PM, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
> Date: Thu, 23 May 2013 18:00:23 +0530
>
>> From: Hebbar Gururaja <gururaja.hebbar-l0cyMroinI0@public.gmane.org>
>>
>> Amend cpsw controller to optionally take a pin control handle and set
>> the state of the pins to:
>>
>> - "default" on boot, resume
>> - "sleep" on suspend()
>>
>> This should make it possible to optimize energy usage for the pins
>> for the suspend/resume cycle.
>>
>> If any of the above pin states are missing in dt, a warning message
>> about the missing state is displayed.
>> If certain pin-states are not available, to remove this warning message
>> pass respective state name with null phandler.
>>
>> Signed-off-by: Hebbar Gururaja <gururaja.hebbar-l0cyMroinI0@public.gmane.org>
>> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
> This still needs some work:
>
>> +		/*
>> +		* Since we continue even when pinctrl node is not found,
>> +		* Invalidate pins as not available. This is to make sure that
>> +		* IS_ERR(pins_xxx) results in failure when used.
>> +		*/
> The second, third, fourth, and fifth lines are not tabbed correctly.  They
> should all be two TABs and a SPACE.
>
> Secondly, comments in the networking are to be formatted:
>
> 	/* Like
> 	 * this.
> 	 */
Will fix this and will resubmit the next version today.

Regards
Mugunthan V N
