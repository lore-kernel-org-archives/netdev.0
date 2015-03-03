From: Sriram Raghunathan <sriram.r@nsn.com>
Subject: About Raw socket, vlan + ip header
Date: Tue, 03 Mar 2015 10:44:15 +0530
Message-ID: <54F54327.7090002@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:41993 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbCCFdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 00:33:47 -0500
Received: from demuprx017.emea.nsn-intra.net ([10.150.129.56])
	by demumfd001.nsn-inter.net (8.14.3/8.14.3) with ESMTP id t235EGbB017433
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 3 Mar 2015 05:14:16 GMT
Received: from [10.143.85.61] ([10.143.85.61])
	by demuprx017.emea.nsn-intra.net (8.12.11.20060308/8.12.11) with ESMTP id t235EFMv006329
	for <netdev@vger.kernel.org>; Tue, 3 Mar 2015 06:14:16 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

My name is Sriram, have a question about raw socket programming.

Writing a socket program where, I'm trying to construct a ether frame
with vlan id and copying ip header there after. By using PF_PACKET
family.

But when I do a sendto, the ip header is stripped off from the
packet. Could you please let me know how to go about?

Having the ip header is necessary for a software here.

Thanks for the time.

Sriram
