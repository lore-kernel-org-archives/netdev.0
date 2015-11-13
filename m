From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net] switchdev: bridge: Check return code is not
 EOPNOTSUPP
Date: Fri, 13 Nov 2015 14:43:19 +0200
Message-ID: <20151113124319.GA31426@colbert.Home>
References: <1447412772-29745-1-git-send-email-idosch@mellanox.com>
 <f9593252b8a9d4733dfa7d22dd71d803@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <stephen@networkplumber.org>,
	<davem@davemloft.net>, <eladr@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>, <nikolay@cumulusnetworks.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0077.outbound.protection.outlook.com ([157.56.112.77]:10144
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753663AbbKMMnd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 07:43:33 -0500
Content-Disposition: inline
In-Reply-To: <f9593252b8a9d4733dfa7d22dd71d803@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Nov 13, 2015 at 02:34:45PM IST, linux@eikelenboom.it wrote:
>On 2015-11-13 12:06, Ido Schimmel wrote:
>> When NET_SWITCHDEV=n, switchdev_port_attr_set simply returns 
>> EOPNOTSUPP.
>> In this case we should not emit errors and warnings to the kernel log.
>
>Hi Ido,
>
>Thanks for your patch!
>
>It fixes these:
>[  207.245442] vif vif-1-0 vif1.0: failed to set HW ageing time
>[  207.245443] xen_bridge: error setting offload STP state on 
>port1(vif1.0)
>
>But i still have these:
>[  335.412194] vif19.0-emu: set_features() failed (-1); wanted 
>0x00000080000048c1, left 0x00000080001b48c9
>[  335.412204] vif19.0-emu: set_features() failed (-1); wanted 
>0x00000080000048c1, left 0x00000080001b48c9
>[  335.412311] vif19.0-emu: set_features() failed (-1); wanted 
>0x00000080000248c9, left 0x00000080001b48c9
>[  335.412319] vif19.0-emu: set_features() failed (-1); wanted 
>0x00000080000048c1, left 0x00000080001b48c9
>[  335.412326] vif19.0-emu: set_features() failed (-1); wanted 
>0x00000080000048c1, left 0x00000080001b48c9
>[  335.535955] vif vif-19-0 vif19.0: set_features() failed (-1); wanted 
>0x0000000400004803, left 0x0000000400114813
>[  335.535965] vif vif-19-0 vif19.0: set_features() failed (-1); wanted 
>0x0000000400004803, left 0x0000000400114813
>[  335.615392] vif vif-19-0 vif19.0: set_features() failed (-1); wanted 
>0x0000000400004803, left 0x0000000400114813
>[  335.615401] xen_bridge: set_features() failed (-1); wanted 
>0x000000801fdb78c9, left 0x000000801fff78e9
>

Yes, this is a different issue and I see that Nik is already working on
it. Can you please try his patch?

http://patchwork.ozlabs.org/patch/544242/
