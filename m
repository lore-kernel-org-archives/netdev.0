From: Don Dutile <ddutile@redhat.com>
Subject: Re: New commands to configure IOV features
Date: Fri, 21 Sep 2012 14:06:11 -0400
Message-ID: <505CAC93.8020304@redhat.com>
References: <5003DC9B.8000706@broadcom.com> <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com> <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com> <5009B186.6000806@genband.com> <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com> <5009ECDF.4090305@genband.com> <500D59BF.9040006@redhat.com> <500D6932.8090306@genband.com> <20120723113607.56ce7aaf@nehalam.linuxnetplumber.net> <C5551D9AAB213A418B7FD5E4A6F30A070C7D9DCD@ORSMSX106.amr.corp.intel.com> <5059A767.2090307@broadcom.com> <20120919085306.00006af9@unknown> <1348083847.2636.37.camel@bwh-desktop.uk.solarflarecom.com> <CAE9FiQXQj_KdWT-mVVsptxiEgGjScgDy_Lp-aXioZ4YAQh1wWQ@mail.gmail.com> <1348094773.2636.85.camel@bwh-desktop.uk.solarflarecom.com> <CAE9FiQVk-uXgLK6dM8q5-Xsh8LO+c-Dd_cEpu2WzJ6Uzt6ztnA@mail.gmail.com> <1
 348104190.4836.61.camel@deadeye.wl.decadent.org.uk> <C5551D9AAB213A418B7FD5E4A6F30A07152FA5F6@ORSMSX106.amr.corp.intel.com> <CAE9FiQXqFnrXT8ibD2zsmeTj-VzXb8sAOjUtryBOxEXj216pQQ@mail.gmail.c!
 om>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-pci <linux-pci@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754579Ab2IUSGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 14:06:21 -0400
In-Reply-To: <CAE9FiQXqFnrXT8ibD2zsmeTj-VzXb8sAOjUtryBOxEXj216pQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2012 01:50 AM, Yinghai Lu wrote:
> On Thu, Sep 20, 2012 at 8:39 AM, Rose, Gregory V
> <gregory.v.rose@intel.com>  wrote:
>>> -----Original Message-----
>>> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>>>>
>>>> could just stop the device and add it back again?
>>>
>>> This is highly disruptive and I think it would be totally unacceptable for
>>> at least networking devices.
>>
>> Agreed.
>>
>> We need the driver callback.
>
> ok, something like attached patches?
>
> ixgbe change need more cleanup from ixgbe guys.
>
> -Yinghai
yuk, no.
I have a set of patches almost done.
It provides 3 sysfs files (enable, disable, num_max_vfs);
callbacks for enable & disable.

i'm tied up until Monday on RHEL6, then I'll switch gears & post a set of patches.
