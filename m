From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: setsockopt(IP_TOS) being privileged or distinct capability?
Date: Sat, 03 Jul 2010 11:58:45 -0600
Message-ID: <4C2F7A55.5090700@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:48349 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754810Ab0GCR6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 13:58:46 -0400
Received: from Philip-Prindevilles-MacBook-Pro.local ([192.168.1.114])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.4/8.14.4) with ESMTP id o63Hwjrr015236
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 3 Jul 2010 11:58:45 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does anyone else think that setsockopt(IP_TOS) should be a privileged 
operation, perhaps using CAP_NET_ADMIN, or maybe even adding separate 
granularity as CAP_NET_TOS?

-Philip

