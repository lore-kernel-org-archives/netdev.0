From: Ben Greear <greearb@candelatech.com>
Subject: radvd and auto-ipv6 address regression from 2.6.31 to 2.6.34+
Date: Fri, 05 Nov 2010 14:24:50 -0700
Message-ID: <4CD47622.5040507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45578 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab0KEVYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 17:24:50 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id oA5LOotg022748
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 5 Nov 2010 14:24:50 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm seeing something strange.  I'm running radvd on a VETH interface (veth0 for argument)
with a single global IPv6 address (and a link-local address).

On hacked 2.6.31, this works as I expect:  The veth0 interface does not gain or lose any
IPv6 addresses and peer VETH port gets an auto-created IPv6 addresses.

On hacked 2.6.34 and 2.6.36 kernels, however, the veth0 gains a new address that appears
to be generated similar to other IPs associated with auto-creation via radvd.

I have not yet tested intervening kernels or physical interfaces between two machines.

So, the question is:  Is the new behaviour on purpose, or is it a regression bug?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

