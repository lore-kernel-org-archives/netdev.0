From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: Hardware capabilities and bonding offload
Date: Mon, 16 Nov 2015 09:29:12 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9AA0D643@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:50911 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbbKPJ3N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 04:29:13 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am looking to offload bond interfaces to hardware for forwarding.  Linux allows for configuring 
a variety of parameters on bonds or slave interfaces.  Not all configurations can be offloaded to 
hardware.  For example, certain hardware cannot support bonds with mode of adaptive load balancing.

When such a configuration is provided by user, we have two options at hand (for platforms supporting
hardware offloads):

1. Reject the configuration.  

2. Handle the bond interface in software.  In a scenario where this bond interface is part
of a bridge interface, for simplicity purpose, all other interfaces in the bridge need to be 
handled in software - which results in a very low packet processing performance.

I'm writing to gather feedback on the approach to take, including any other suggestions.
We have discussed this briefly in our weekly netdev meeting, and I received votes for
option #1.

Thanks
Prem
