From: Don Dutile <ddutile@redhat.com>
Subject: Re: New commands to configure IOV features
Date: Fri, 21 Sep 2012 16:08:16 -0400
Message-ID: <505CC930.5070807@redhat.com>
References: <5003DC9B.8000706@broadcom.com> <5009B186.6000806@genband.com> <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com> <5009ECDF.4090305@genband.com> <500D59BF.9040006@redhat.com> <500D6932.8090306@genband.com> <20120723113607.56ce7aaf@nehalam.linuxnetplumber.net> <C5551D9AAB213A418B7FD5E4A6F30A070C7D9DCD@ORSMSX106.amr.corp.intel.com> <5059A767.2090307@broadcom.com> <20120919085306.00006af9@unknown> <1348083847.2636.37.camel@bwh-desktop.uk.solarflarecom.com> <CAE9FiQXQj_KdWT-mVVsptxiEgGjScgDy_Lp-aXioZ4YAQh1wWQ@mail.gmail.com> <1348094773.2636.85.camel@bwh-desktop.uk.solarflarecom.com> <CAE9FiQVk-uXgLK6dM8q5-Xsh8LO+c-Dd_cEpu2WzJ6Uzt6ztnA@mail.gmail.com> <1348104190.4836.61.camel@deadeye.wl.decadent.org.uk> <C5551D9AAB213A418B7FD5E4A6F30A07152FA5F6@ORSMSX106.amr.corp.intel.co
 m> <CAE9FiQXqFnrXT8ibD2zsmeTj-VzXb8sAOjUtryBOxEXj216pQQ@mail.gmail.com> <505CAC93.8020304@redhat.com> <CAE9FiQW4vY3SwAt1TGhSa=bcmKnzxS96b9HGoU5_CDb3FRvGVA@mail.gmail.com>
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
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAE9FiQW4vY3SwAt1TGhSa=bcmKnzxS96b9HGoU5_CDb3FRvGVA@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/21/2012 03:49 PM, Yinghai Lu wrote:
> On Fri, Sep 21, 2012 at 11:06 AM, Don Dutile<ddutile@redhat.com>  wrote:
>>>
>>> ok, something like attached patches?
>>>
>>> ixgbe change need more cleanup from ixgbe guys.
>>>
>> yuk, no.
>> I have a set of patches almost done.
>
> good. includes update to those network drivers?
>
>> It provides 3 sysfs files (enable, disable, num_max_vfs);
>> callbacks for enable&  disable.
>
> why using three? only pass max_vfs should be enough...
>
> aka pass 0 mean disabling, pass other value mean enabling.
>
could do that.  but I wouldn't use 'max_vfs'; I would recommend
'num_vfs', as max implies, er, um, the maximum, and what one
wants is to be able to enable a number from 1->max_vfs.
'max_vfs' will be provided by another file.

>>
>> i'm tied up until Monday on RHEL6, then I'll switch gears&  post a set of
>> patches.
>
> so that is your employer 'sinternal policy? for RHEL 6 kernel first,
> then upstream kernel?
No, I have deadlines for RHEL6 for *other work* until Monday.  After that,
I can re-focus on upstream work.  Some of us actually have other work than
just upstream.... crazy talk, I know! ;-)

> thought RH only accept backporting only patches get into upstream already.
>
yup. 'upstream first' is the rule at RH before it gets into a RHEL release...
and sometimes that isn't sufficient!

Have a beer, enjoy the weekend, posting forthcoming next week!

> -Yinghai
