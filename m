From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: Question regarding MAC address configuraton with VLAN devices
Date: Tue, 7 Apr 2015 13:16:52 +0000
Message-ID: <31AFFC7280259C4184970ABA9AFE8B93E093DDB3@avmb3.qlogic.org>
References: <31AFFC7280259C4184970ABA9AFE8B93E0930C40@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Manish Chopra <manish.chopra@qlogic.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:50615 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752825AbbDGNQ5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 09:16:57 -0400
In-Reply-To: <31AFFC7280259C4184970ABA9AFE8B93E0930C40@avmb3.qlogic.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Manish Chopra
> Sent: Thursday, April 02, 2015 12:46 AM
> To: Patrick McHardy
> Cc: netdev; Yuval Mintz
> Subject: Question regarding MAC address configuraton with VLAN devices
> 
> 
> Hello Patrick,
> 
> I have a question regarding MAC address configuration of network devices
> specially when VLANs are configured on that. Can you please help to address?
> 
> When user changes MAC address of a base network device [e.g., via ifconfig]
> why existing VLAN device on top of that would add it's previous MAC address to
> unicast list of base device instead of adapting the new MAC address in it's own
> net device?
> 
> What we are trying to achieve here is that -
> 
> For a VF, if Hypervisor/Administrator has forced a MAC [e.g., via iproute2] then
> as a part of "learning process [of the new hypervisor forced mac] done by VF
> driver", it will simply call "call_netdevice_notifiers(NETDEV_CHANGEADDR,
> dev)", which would notify the address change to VLAN interfaces configured on
> top of VF device and they will adapt the hypervisor forced MAC too.
> But that's not seems to be the behavior here, instead VLAN device on top of the
> VF device seems to be adding It's previous MAC address to unicast list of base VF
> device. This configuration will not take effect [since PF is blocking the VF's
> additional unicast MACs, if once a MAC has been forced to the VF], thus
> effectively the VLAN interface will never receive traffic with it's configured MAC.
> 
>

Hello Patrick,
Not sure if you have gone through this email, just to remind you again if you have missed it.

Thanks,
Manish 

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
