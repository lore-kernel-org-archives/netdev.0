From: Manish Chopra <manish.chopra@qlogic.com>
Subject: MPLS in Linux
Date: Tue, 5 Jul 2016 11:28:21 +0000
Message-ID: <CY1PR11MB041020E739DE80A007366A1193390@CY1PR11MB0410.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: "ebiederm@xmission.com" <ebiederm@xmission.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0108.outbound.protection.outlook.com ([104.47.40.108]:61206
	"EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751599AbcGEMB4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 08:01:56 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Folks,

I am trying to play a bit with MPLS on linux. I have basically two servers connected back to back [No switch/router in between those] using NIC devices.
Linux kernels are configured for MPLS and all required modules [mpls_gso, mpls_router, mpls_iptunnel etc.] are loaded on the setups.

To visualize it  - here is the configuration with my setup.

Host A                                     Host B
########|                 	|########
        Eth0  <===========> Eth1
########|                	|########
IP: 192.168.44.20           IP: 192.168.44.21    

I want to send MPLS packets/traffic between these NICs [Eth0 and Eth1] in the above mentioned scenario - is there any way to achieve this in back to back connection topology ??
If so, can anyone supply necessary configurations needs to be done on the hosts via iproute2 utility ??
Or can MPLS be tested only using routers topology, not with back to back connection ?

Another question I have is - which NIC offloads can be supported with MPLS ?

Thanks,
Manish
