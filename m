From: "Hong Hui Xiao" <xiaohhui@cn.ibm.com>
Subject: [Question/Bug] Should the priority of ip rule be unique?
Date: Fri, 8 Jan 2016 14:32:08 +0800
Message-ID: <201601080632.u086WOPd003565@d23av04.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:45285 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbcAHGdD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 01:33:03 -0500
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <xiaohhui@cn.ibm.com>;
	Fri, 8 Jan 2016 16:33:01 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A8C0B2BB0052
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 17:32:58 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u086Wqht20512880
	for <netdev@vger.kernel.org>; Fri, 8 Jan 2016 17:33:00 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u086WQ6Z003783
	for <netdev@vger.kernel.org>; Fri, 8 Jan 2016 17:32:26 +1100
Received: from e39.co.us.ibm.com (e39.boulder.ibm.com [9.17.249.49])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id u086WOPd003565
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 8 Jan 2016 17:32:25 +1100
Received: from localhost
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <xiaohhui@cn.ibm.com>;
	Thu, 7 Jan 2016 23:32:16 -0700
Received: from /spool/local
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <netdev@vger.kernel.org> from <xiaohhui@cn.ibm.com>;
	Fri, 8 Jan 2016 06:32:12 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>From the man page of ip rule at [1], it says that "Each rule should have 
an explicitly set unique priority value." It is reasonable to have unique 
priority for ambiguous rules.
But I have a set of unambiguous ip rules, do I still need to set the 
priority of to be unique? In practice, I can set ip rules with duplicated 
priority, and things works as expected. I want to confirm with iproute 
developers if this is a support usecase. If so, the information in man 
page may need updates.

5000: from all fwmark 0x4000000/0xffff0000 lookup table0 
5000: from all fwmark 0x4010000/0xffff0000 lookup table1 
5000: from all fwmark 0x4020000/0xffff0000 lookup table2 
5000: from all fwmark 0x4030000/0xffff0000 lookup table3 


[1] http://man7.org/linux/man-pages/man8/ip-rule.8.html (search for 
"unique")
