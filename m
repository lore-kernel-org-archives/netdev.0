From: Mark Jackson <mpfj-list@newflow.co.uk>
Subject: Re: [PATCHv2] am33xx: cpsw: default to ethernet hwaddr from efuse
 if not defined in dt
Date: Mon, 08 Jul 2013 13:42:04 +0100
Message-ID: <51DAB39C.7090106@newflow.co.uk>
References: <1358461134-13452-1-git-send-email-jacmet@sunsite.dk> <50F8DA3A.3090406@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Peter Korsgaard <jacmet@sunsite.dk>, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	hvaibhav@ti.com, richardcochran@gmail.com, tony@atomide.com,
	michal.bachraty@gmail.com, michal.bachraty@streamunlimited.com
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <50F8DA3A.3090406@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/01/13 05:14, Mugunthan V N wrote:
> On 1/18/2013 3:48 AM, Peter Korsgaard wrote:
>> When booting with CONFIG_ARM_APPENDED_DTB (either because of using an old
>> U-Boot, not wanting the hassle of 2 files or when using Falcon fast boot
>> mode in U-Boot), nothing updates the ethernet hwaddr specified for the
>> CPSW slaves, causing the driver to use a random hwaddr, which is some times
>> troublesome.
>>
>> The am33xx has unique ethernet hwaddrs programmed in the efuse, so it makes
>> more sense to default to these rather than random ones. Add a fixup step
>> which adds mac-address dt properties using the efuse addresses if the DTB
>> didn't contain valid ones.
>>
>> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
>>
> 
> This implementation looks fine.
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Tested-by: Mark Jackson <mpfj-list@newflow.co.uk>

