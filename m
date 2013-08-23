From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: Re: [PATCH v4 3/5] net: ethernet: cpsw: introduce ti,am3352-cpsw
 compatible string
Date: Fri, 23 Aug 2013 13:19:31 -0400
Message-ID: <521799A3.7080706@ti.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com>
 <1377267365-24057-4-git-send-email-zonque@gmail.com>
 <52177052.1030308@ti.com> <52178E20.5040404@gmail.com>
 <52179448.1020906@ti.com> <5217974B.5090503@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, sergei.shtylyov@cogentembedded.com, d-gerlach@ti.com,
 netdev@vger.kernel.org, vaibhav.bedia@ti.com, Daniel Mack <zonque@gmail.com>,
 devicetree@vger.kernel.org, bcousson@baylibre.com, ujhelyi.m@gmail.com,
 linux-omap@vger.kernel.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <5217974B.5090503@ti.com>
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

On Friday 23 August 2013 01:09 PM, Sekhar Nori wrote:
> 
> 
> On 8/23/2013 10:26 PM, Santosh Shilimkar wrote:
>> On Friday 23 August 2013 12:30 PM, Daniel Mack wrote:
>>> On 23.08.2013 16:23, Santosh Shilimkar wrote:
>>>> On Friday 23 August 2013 10:16 AM, Daniel Mack wrote:
>>>
>>>>> +static const struct of_device_id cpsw_of_mtable[] = {
>>>>> +	{
>>>>> +		.compatible	= "ti,am3352-cpsw",
>>>>
>>>> I didn't notice this earlier, but can't you use the IP version
>>>> as a compatible instead of using a SOC name. Whats really SOC specific
>>>> on this IP ? Sorry i have missed any earlier discussion on this but
>>>> this approach doesn't seem good. Its like adding SOC checks in the
>>>> driver subsystem.
>>>
>>> As I already mentioned in the cover letter and in the commit message, I
>>> just don't know which criteria makes most sense here.
>>>
>>> On a general note, I would say that chances that this exactly IP core
>>> with the same version number will appear on some other silicon which
>>> doesn't support the control mode register in an AM33xx fashion, is not
>>> necessarily negligible.
>>>
>>> So what that new compatible string denotes is the cpsw in a version as
>>> found on am3352 SoCs, which is actually exactly what it does.
>>>
>>> I don't have a strong opinion here, but see your point. I just don't
>>> have a better idea on how to treat that.
>>>
>> So just stick the IP version or call it cpsw-v1... cpsw-v2 etc.
> 
> If this could be handled using IP version then the right way would be to
> just read the IP version from hardware and use it. No need of DT property.
> 
Thats fine as well but I thought the patch needed additional properties like
CM reg-address come from DT and hence the separate compatible. If you can
manage without that, thats even better.

Regards,
Santosh
