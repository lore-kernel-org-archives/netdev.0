From: "Elluru, Krishna Mohan" <elluru.kri.mohan@hpe.com>
Subject: VRF_DEVICE integration plan
Date: Sun, 24 Apr 2016 04:07:38 +0000
Message-ID: <AT5PR84MB00652788CA3C3F63146F9C08CA610@AT5PR84MB0065.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0123.outbound.protection.outlook.com ([207.46.100.123]:17920
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751368AbcDXFkm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 01:40:42 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI Netdev team,

 	Greetings. We have been monitoring the vrf device approach for l3 isolation from cumulus networks and we are currently interested in validating it. We have following questions on them and hoping to get answers from you/concerned team.

1. As per the linux documentation, there are known limits on if_index lookup, as the incoming if_index is changed to vrf_device index and thus an application receiving this packet will perceive this as a vrf_device packet, than right if_index. I saw you mentioned about a special flag to identify the origin, but didn't see the same in the latest linux 4.4.2 version code. Is there a patch expected for it?

2. What are the future additions planned for this approach? Are there any ipv4 and ipv6 known bugs with vrf_device model? 

3. It has been said in the documentation that, with addition of cgroup functionality for vrf device, with net_admin capabilities, we should be able to add an interface to vrf_device, currently it is not so. Any timelines on these?

4. Currently the changes are available and portable from 4.3.x onwards. Is there a plan to port them to previous kernel versions? 

5. Is there a possibility of enabling secondary level lookup, to give a leak functionality to parent route table from device local route table? I tested with veth pair, configured one as default gateway, it is possible to forward traffic b/w the interfaces, looking for cleaner method.

6. With "VRF Device" in place,  please confirm if there are any plans to add VRF support for applications like 

	1.	Ping
	2.	Traceroute
	3.	DNS-Client [glibc]

	In case of DNS-Client, most of the name resolution APIs will have to consider the VRF to do the lookup in  and the way the domain-name/name-server configuration is stored.

Please revert back, if you need more clarification on the questions.

Thanks in Advance
Krishna Mohan
