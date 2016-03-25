From: Ben Greear <greearb@candelatech.com>
Subject: Re: veth regression with =?UTF-8?B?ImRvbuKAmXQgbW9kaWZ5IGlwX3N1bQ==?=
 =?UTF-8?B?bWVkOyBkb2luZyBzbyB0cmVhdHMgcGFja2V0cyB3aXRoIGJhZCBjaGVja3N1bXM=?=
 =?UTF-8?B?IGFzIGdvb2QuIg==?=
Date: Thu, 24 Mar 2016 21:34:57 -0700
Message-ID: <56F4BFF1.8010806@candelatech.com>
References: <56F463D6.7080406@candelatech.com> <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com> <56F4810A.9060904@candelatech.com> <56F49036.8050902@candelatech.com> <56F490B2.3090603@candelatech.com> <CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:58343 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbcCYEfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 00:35:03 -0400
In-Reply-To: <CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/24/2016 06:44 PM, Vijay Pandurangan wrote:
> Oops, I think my last email didn't go through due to an inadvertent
> html attachment from my phone mail client.
>
> Can you send us a copy of a packet you're sending and/or confirm that
> the IP and UDP4 checksums are set correctly in the packet?
>
> If those are set right, I think we need to read through the networking
> code again to see why this is broken...

Wireshark decodes the packet as having no checksum errors.

I think the contents of the packet is correct, but the 'ip_summed'
field is set incorrectly to 'NONE' when transmitting on a raw packet
socket.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
