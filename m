From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [PATCH net] switchdev: bridge: Check return code is not
 EOPNOTSUPP
Date: Fri, 13 Nov 2015 14:34:37 +0100
Message-ID: <4273ed30b9cb410589c1ee3a2710cc3f@eikelenboom.it>
References: <1447412772-29745-1-git-send-email-idosch@mellanox.com>
 <f9593252b8a9d4733dfa7d22dd71d803@eikelenboom.it>
 <20151113124319.GA31426@colbert.Home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	davem@davemloft.net, eladr@mellanox.com,
	Jiri Pirko <jiri@mellanox.com>, nikolay@cumulusnetworks.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:39408 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbbKMNgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 08:36:55 -0500
In-Reply-To: <20151113124319.GA31426@colbert.Home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-11-13 13:43, Ido Schimmel wrote:
> Fri, Nov 13, 2015 at 02:34:45PM IST, linux@eikelenboom.it wrote:
>> On 2015-11-13 12:06, Ido Schimmel wrote:
>>> When NET_SWITCHDEV=n, switchdev_port_attr_set simply returns
>>> EOPNOTSUPP.
>>> In this case we should not emit errors and warnings to the kernel 
>>> log.
>> 
>> Hi Ido,
>> 
>> Thanks for your patch!
>> 
>> It fixes these:
>> [  207.245442] vif vif-1-0 vif1.0: failed to set HW ageing time
>> [  207.245443] xen_bridge: error setting offload STP state on
>> port1(vif1.0)
>> 
>> But i still have these:
>> [  335.412194] vif19.0-emu: set_features() failed (-1); wanted
>> 0x00000080000048c1, left 0x00000080001b48c9
>> [  335.412204] vif19.0-emu: set_features() failed (-1); wanted
>> 0x00000080000048c1, left 0x00000080001b48c9
>> [  335.412311] vif19.0-emu: set_features() failed (-1); wanted
>> 0x00000080000248c9, left 0x00000080001b48c9
>> [  335.412319] vif19.0-emu: set_features() failed (-1); wanted
>> 0x00000080000048c1, left 0x00000080001b48c9
>> [  335.412326] vif19.0-emu: set_features() failed (-1); wanted
>> 0x00000080000048c1, left 0x00000080001b48c9
>> [  335.535955] vif vif-19-0 vif19.0: set_features() failed (-1); 
>> wanted
>> 0x0000000400004803, left 0x0000000400114813
>> [  335.535965] vif vif-19-0 vif19.0: set_features() failed (-1); 
>> wanted
>> 0x0000000400004803, left 0x0000000400114813
>> [  335.615392] vif vif-19-0 vif19.0: set_features() failed (-1); 
>> wanted
>> 0x0000000400004803, left 0x0000000400114813
>> [  335.615401] xen_bridge: set_features() failed (-1); wanted
>> 0x000000801fdb78c9, left 0x000000801fff78e9
>> 
> 
> Yes, this is a different issue and I see that Nik is already working on
> it. Can you please try his patch?
> 
> http://patchwork.ozlabs.org/patch/544242/

Yeah that suppresses the warning, thx !

--
Sander
