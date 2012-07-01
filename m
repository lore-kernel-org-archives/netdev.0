From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: New commands to configure IOV features
Date: Sun, 1 Jul 2012 14:09:32 +0300
Message-ID: <4FF02FEC.1030405@broadcom.com>
References: <4FA7AF62.8000405@broadcom.com>
 <20120507081634.000003f8.gregory.v.rose@intel.com>
 <4FE9A963.7020602@broadcom.com> <20120626101903.0000791c@unknown>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Greg Rose" <gregory.v.rose@intel.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: linux-pci@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20120626101903.0000791c@unknown>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>>>> I've tried to figure out if there was a standard interface
>>>> (ethtool/iproute) through which a user could configure the number
>>>> of vfs in his system.
>>>>
>>>> I've seen the RFC suggested in
>>>> http://markmail.org/thread/qblfcv7zbxsxp7q6, and
>>>> http://markmail.org/thread/fw54dcppmxuxoe6n, but failed to see any
>>>> later references to it (commits or further discussion on this
>>>> topic).
>>>>
>>>> How exactly are things standing with these RFCs? Were they
>>>> abandoned?
>>>
>>> The only way to configure the number of VFs continues to be through
>>> the max_vfs module parameter.  I've got a patch to do it through
>>> ethtool sitting on the back burner but due to other requirements of
>>> my day job I've not been able to work on it since last fall.
>>>
>>> - Greg
>>
>>
>> Hi Ben,
>>
>> If I want to pick the RFCs and add support for configuring the number
>> of VFs - do you think ethtool's the right place for such added
>> support?
>>
>> I'm asking since as far as I can see, ethtool (today) doesn't contain
>> any features related to virtual functions.
> 
> I think a PCI utility tool would be better, SR-IOV is not limited to
> network devices.  That's one of the reasons I dropped the RFC.  I
> haven't gotten back to the idea since then due to my day job keeping me
> pretty busy.
> 
> - Greg


I'm adding the linux-pci guys, since they (obviously) are the experts in
these topics.

Is there any PCI utility (or at least an existing kernel API) which is
suitable for adding this sort of functionality?

Thanks,
Yuval
