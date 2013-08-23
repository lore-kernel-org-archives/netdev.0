From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [PATCH v4 3/5] net: ethernet: cpsw: introduce ti,am3352-cpsw
 compatible string
Date: Fri, 23 Aug 2013 22:39:31 +0530
Message-ID: <5217974B.5090503@ti.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-4-git-send-email-zonque@gmail.com> <52177052.1030308@ti.com> <52178E20.5040404@gmail.com> <52179448.1020906@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <zonque@gmail.com>, <netdev@vger.kernel.org>,
	<bcousson@baylibre.com>, <sergei.shtylyov@cogentembedded.com>,
	<davem@davemloft.net>, <ujhelyi.m@gmail.com>,
	<mugunthanvnm@ti.com>, <vaibhav.bedia@ti.com>, <d-gerlach@ti.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <52179448.1020906@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 8/23/2013 10:26 PM, Santosh Shilimkar wrote:
> On Friday 23 August 2013 12:30 PM, Daniel Mack wrote:
>> On 23.08.2013 16:23, Santosh Shilimkar wrote:
>>> On Friday 23 August 2013 10:16 AM, Daniel Mack wrote:
>>
>>>> +static const struct of_device_id cpsw_of_mtable[] = {
>>>> +	{
>>>> +		.compatible	= "ti,am3352-cpsw",
>>>
>>> I didn't notice this earlier, but can't you use the IP version
>>> as a compatible instead of using a SOC name. Whats really SOC specific
>>> on this IP ? Sorry i have missed any earlier discussion on this but
>>> this approach doesn't seem good. Its like adding SOC checks in the
>>> driver subsystem.
>>
>> As I already mentioned in the cover letter and in the commit message, I
>> just don't know which criteria makes most sense here.
>>
>> On a general note, I would say that chances that this exactly IP core
>> with the same version number will appear on some other silicon which
>> doesn't support the control mode register in an AM33xx fashion, is not
>> necessarily negligible.
>>
>> So what that new compatible string denotes is the cpsw in a version as
>> found on am3352 SoCs, which is actually exactly what it does.
>>
>> I don't have a strong opinion here, but see your point. I just don't
>> have a better idea on how to treat that.
>>
> So just stick the IP version or call it cpsw-v1... cpsw-v2 etc.

If this could be handled using IP version then the right way would be to
just read the IP version from hardware and use it. No need of DT property.

Thanks,
Sekhar
