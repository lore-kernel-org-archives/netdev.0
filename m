From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 0/9] Phy, mdiobus, and netdev struct device fixes
Date: Thu, 24 Sep 2015 23:05:22 -0700 (PDT)
Message-ID: <20150924.230522.2080343670036893514.davem@davemloft.net>
References: <20150924191754.GC21513@n2100.arm.linux.org.uk>
	<5604A5EC.7060401@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sgoutham-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, rric-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, isubramanian-qTEPVZfXA3Y@public.gmane.org,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org, kchudgar-qTEPVZfXA3Y@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5604A5EC.7060401-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 24 Sep 2015 18:39:56 -0700

> On 24/09/15 12:17, Russell King - ARM Linux wrote:
>> Hi,
>> 
>> The third version of this series fixes the build error which David
>> identified, and drops the broken changes for the Cavium Thunger BGX
>> ethernet driver as this driver requires some complex changes to
>> resolve the leakage - and this is best done by people who can test
>> the driver.
>> 
>> Compared to v2, the only patch which has changed is patch 6
>>   "net: fix phy refcounting in a bunch of drivers"
>> 
>> I _think_ I've been able to build-test all the drivers touched by
>> that patch to some degree now, though several of them needed the
>> Kconfig hacked to allow it (not all had || COMPILE_TEST clause on
>> their dependencies.)
> 
> Tested-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Thanks for fixing that.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
