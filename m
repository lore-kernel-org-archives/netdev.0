From: Don Dutile <ddutile@redhat.com>
Subject: Re: New commands to configure IOV features
Date: Tue, 17 Jul 2012 15:29:04 -0400
Message-ID: <5005BD00.4090106@redhat.com>
References: <4FA7AF62.8000405@broadcom.com> <20120507081634.000003f8.gregory.v.rose@intel.com> <4FE9A963.7020602@broadcom.com> <20120626101903.0000791c@unknown> <1341859155.2535.43.camel@bwh-desktop.uk.solarflarecom.com> <4FFB4985.3040507@genband.com> <5003DC9B.8000706@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Chris Friesen <chris.friesen@genband.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-pci@vger.kernel.org
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <5003DC9B.8000706@broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/16/2012 05:19 AM, Yuval Mintz wrote:
>
>>>>> If I want to pick the RFCs and add support for configuring the number
>>>>> of VFs - do you think ethtool's the right place for such added
>>>>> support?
>>>>>
>>>> I think a PCI utility tool would be better, SR-IOV is not limited to
>>>> network devices.  That's one of the reasons I dropped the RFC.  I
>>>> haven't gotten back to the idea since then due to my day job keeping me
>>>> pretty busy.
>>>
>>> For what it's worth, I agree with this.
>>
>>  From my perspective it would be ideal if this could be exported via /sys or something
>>
>
>
> Well, obviously unless there was a sudden change in our stance regarding
> sysfs we will not head that way.
>
> This thread got no replies from the pci community, and I'm unfamiliar
> with such a tool.
>
> Dave, What's your stance in the matter - do you wish us to continue pursuing
> some pci tool (which might or might not exist), or instead work on
> a networking solution to this issue?
>
> Do you happen to know such a tool?
>
> Thanks,
> Yuval
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Yuval (et. al.),

Not seeing the original thread on netdev,
I just had a recent discussion w/Greg Rose about providing
sysfs-based, VF enable/disable methods.
I was told that historically, VF enablement started as a sysfs-based
function, was debated and pushed toward a device/driver-specific method,
as it is implemented today.   Now, with some experience with SRIOV and
its use in the virtualization space, the discussion has renewed as to whether
a sysfs-based enable/disable method should be resurrected, so it
provides a more generic method for virtualization tools/api's to
manage SRIOV/VF devices.

I was hoping to discuss this topic with a number of folks at
LinuxCon/Plumbers/KS when the PCI mini-summit is held, to gain
further insight, or be brought up to speed on past history,
and review current uses/status of VFs.

WRT SRIOV-nic devices, the thinking goes that protocol-level
parameters associated with VFs should use protocol-specific interfaces,
e.g., ethtool, ip link set, etc. for Ethernet VFs.
Thus, the various protocol control functions/tools should
be used to control VF parameters, as one would for a physical device
of that protocol/class.

- Don
