From: Joyce Yu - System Software <joyce.yu@oracle.com>
Subject: What could be the cause of reboot hang on iptables script with niu
 driver interface up in RHL6.0 systems
Date: Wed, 11 May 2011 11:40:36 -0700
Message-ID: <4DCAD824.7010000@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:25856 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab1EKSkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 14:40:39 -0400
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id p4BIeba6010938
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 11 May 2011 18:40:38 GMT
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id p4BIeaYm026711
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 11 May 2011 18:40:36 GMT
Received: from abhmt007.oracle.com (abhmt007.oracle.com [141.146.116.16])
	by acsmt356.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id p4BIeV2f017195
	for <netdev@vger.kernel.org>; Wed, 11 May 2011 13:40:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Some of my Redhat 6.0 systems always have reboot hang problem on 
iptables script with niu driver interface up. After adding some debug 
stuff, I can see the system alway hang on " modprobe -r xt_state". What 
could be the cause of it? Does niu driver need to handle some 
calls/ioctls that currently not implemented in the niu driver?

Thanks,
Joyce

