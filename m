From: annie li <annie.li@oracle.com>
Subject: GroupOrderList does not work for windows8?
Date: Wed, 17 Apr 2013 10:23:13 -0400
Message-ID: <516EB051.3000405@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51150 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966477Ab3DQOXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 10:23:17 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r3HENFaP028697
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 14:23:16 GMT
Received: from userz7022.oracle.com (userz7022.oracle.com [156.151.31.86])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r3HENFDQ021944
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 14:23:15 GMT
Received: from abhmt102.oracle.com (abhmt102.oracle.com [141.146.116.54])
	by userz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r3HENEO4023712
	for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 14:23:14 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I need to boot my bus driver before pci dirver, and I put my driver tag 
in front of pci tag in Boot Bus Extender key of GroupOrderList, just 
like suggested in http://support.microsoft.com/kb/115486.

This way works well for window2012, but it never works for windows8. It 
seems windows8 does not care about any change I did in GroupOrderList. I 
enabled Verbose boot and the log shows pci is loaded before my bus 
driver even though I put the tag of my bus driver in front of tag of pci 
in GroupOrderList. Is it a known issue in windows8? Anyone hit similar 
issue? Thanks.

Thanks
Annie
