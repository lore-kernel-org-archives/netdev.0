From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [PATCH v2 5/5] ARM: dts: am33xx: adopt to cpsw changes
Date: Fri, 23 Aug 2013 15:10:34 +0530
Message-ID: <52172E12.2000908@ti.com>
References: <1377247417-27386-1-git-send-email-zonque@gmail.com>
 <1377247417-27386-6-git-send-email-zonque@gmail.com>
 <52172B54.8020201@ti.com> <52172CB0.9030204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, sergei.shtylyov@cogentembedded.com, d-gerlach@ti.com,
 netdev@vger.kernel.org, vaibhav.bedia@ti.com, devicetree@vger.kernel.org,
 ujhelyi.m@gmail.com, linux-omap@vger.kernel.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <52172CB0.9030204@gmail.com>
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

On Friday 23 August 2013 03:04 PM, Daniel Mack wrote:
> On 23.08.2013 11:28, Sekhar Nori wrote:
>> On Friday 23 August 2013 02:13 PM, Daniel Mack wrote:
>>> This third memory region just denotes one single register in the CONTROL
>>> module block. The driver uses that in order to set the correct physical
>>> ethernet interface modes.
>>>
>>> Also update the compatible string to make use of the am335x specific
>>> features of the cpsw driver.
>>>
>>> Signed-off-by: Daniel Mack <zonque@gmail.com>
>>> ---
>>>  arch/arm/boot/dts/am33xx.dtsi | 5 +++--
>>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
>>> index a785b95..1a1e9dd 100644
>>> --- a/arch/arm/boot/dts/am33xx.dtsi
>>> +++ b/arch/arm/boot/dts/am33xx.dtsi
>>> @@ -446,7 +446,7 @@
>>>  		};
>>>  
>>>  		mac: ethernet@4a100000 {
>>> -			compatible = "ti,cpsw";
>>> +			compatible = "ti,am3352-cpsw";
>>
>> Please keep this as
>>
>> 	compatible = "ti,am3352-cpsw", "ti,cpsw";
>>
>> so users can upgrade the DTB or kernel independently. Apart from this
>> the series looks good to me.
> 
> Ok, thanks. Given that this last patch will be merged through another
> tree, can I just resend it separately, while David takes the rest as it is?

Ideally you could, but there are some bugs in the way compatible string
in handled and due to this I suspect you need to reorder
cpsw_of_mtable[] to match correctly. Not sure if the bug has been fixed
in recent -rcs. Please check if modifying just this patch works and then
go ahead and post.

Please Cc Benoit Cousson <bcousson@baylibre.com> on your next submission
as he is the one who picks up DT patches for OMAP.

Thanks,
Sekhar
