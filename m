From: Mattias =?utf-8?Q?R=C3=B6nnblom?= <hofors@lysator.liu.se>
Subject: Re: VLAN egress performance
Date: Mon, 08 Feb 2010 17:58:57 +0100
Message-ID: <87aavjfyum.fsf@isengard.friendlyfire.se>
References: <87wrynrk37.fsf@isengard.friendlyfire.se>
	<4B700DF5.1080406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lysator.liu.se ([130.236.254.3]:46652 "EHLO
	mail.lysator.liu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116Ab0BHQ66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 11:58:58 -0500
In-Reply-To: <4B700DF5.1080406@trash.net> (Patrick McHardy's message of "Mon\, 08 Feb 2010 14\:13\:25 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

>> Ingress VLAN  Egress VLAN  Packet Rate    CPU utilization (all cores)
>> No            No           5.0 Mpacket/s  ~70%
>> Yes           No           5.0 Mpacket/s  ~75%
>> No            Yes          1.4 Mpacket/s  ~26%
>> Yes           Yes          1.3 Mpacket/s  ~26%
>> 
> 2.6.32 contains VLAN multiqueue support and should scale better.

OK, excellent. I tried out 2.6.32.7 and it did 4.0 Mpacket/s with VLAN
on both ingress and egress, and ~4.7 Mpacket/s without any VLANs.

Thanks,
     Mattias
