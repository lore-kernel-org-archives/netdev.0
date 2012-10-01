From: Don Dutile <ddutile@redhat.com>
Subject: Re: New commands to configure IOV features
Date: Mon, 01 Oct 2012 10:12:43 -0400
Message-ID: <5069A4DB.3030201@redhat.com>
References: <5003DC9B.8000706@broadcom.com> <5009ECDF.4090305@genband.com> <500D59BF.9040006@redhat.com> <500D6932.8090306@genband.com> <20120723113607.56ce7aaf@nehalam.linuxnetplumber.net> <C5551D9AAB213A418B7FD5E4A6F30A070C7D9DCD@ORSMSX106.amr.corp.intel.com> <5059A767.2090307@broadcom.com> <20120919085306.00006af9@unknown> <1348083847.2636.37.camel@bwh-desktop.uk.solarflarecom.com> <CAE9FiQXQj_KdWT-mVVsptxiEgGjScgDy_Lp-aXioZ4YAQh1wWQ@mail.gmail.com> <1348094773.2636.85.camel@bwh-desktop.uk.solarflarecom.com> <CAE9FiQVk-uXgLK6dM8q5-Xsh8LO+c-Dd_cEpu2WzJ6Uzt6ztnA@mail.gmail.com> <1348104190.4836.61.camel@deadeye.wl.decadent.org.uk> <C5551D9AAB213A418B7FD5E4A6F30A07152FA5F6@ORSMSX106.amr.corp.intel.com> <CAE9FiQXqFnrXT8ibD2zsmeTj-VzXb8sAOjUtryBOxEXj216pQQ@mail.gmail.com> <505CAC93.8020304@r
 edhat.com> <CAE9FiQW4vY3SwAt1TGhSa=bcmKnzxS96b9HGoU5_CDb3FRvGVA@mail.gmail.com> <505CC930.5070807@redhat.com> <5067E90B.2030908@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yinghai@kernel.org>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-pci <linux-pci@vger.kernel.org>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51383 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753035Ab2JAOM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 10:12:57 -0400
In-Reply-To: <5067E90B.2030908@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2012 02:39 AM, Yuval Mintz wrote:
>>>> yuk, no.
>>>> I have a set of patches almost done.
>>>> i'm tied up until Monday on RHEL6, then I'll switch gears&   post a set of
>>>> patches.
>
> hi Don - anything new about this incoming patch-series?
>
>>>
>>> so that is your employer 'sinternal policy? for RHEL 6 kernel first,
>>> then upstream kernel?
>> No, I have deadlines for RHEL6 for *other work* until Monday.  After that,
>> I can re-focus on upstream work.  Some of us actually have other work than
>> just upstream.... crazy talk, I know! ;-)
>
>
I should have the sysfs-level patches done & posted today.
Need another day or 2 to get a driver refactored to use it (ixgbe).

Although the patches will enable per-device sriov enablement/disablement,
further thought on tools that will stack on top of it, probably will need
to augment a new pci sysfs directory that tools can find sriov devices
quicker/easier w/o traversing the entire /sys/bus/pci/devices tree
searching for a 'sriov_max_vfs' file, but, I can do that as a follow-on patch.
I'm thinking of what is done now with virtfn<X> linked files in the pf,
but the inverse link in a directory, like /sys/bus/pci/sriov.

Then there's the additional patches needed to do an 'all', or <DOMAIN:B:D.F>
qualified enable/disable from a per-sysfs-driver perspective. ... fun stuff!
