From: "Cloutier, Joseph (Joseph)" <joseph.cloutier@alcatel-lucent.com>
Subject: FW: How do I get bug fix for ping in iputils?
Date: Wed, 16 Nov 2011 11:41:18 -0600
Message-ID: <7D3B6706FA74174B8C1AC24710890745136E7B3338@USNAVSXCHMBSA1.ndc.alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ihemail4.lucent.com ([135.245.0.39]:38806 "EHLO
	ihemail4.lucent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756278Ab1KPRl2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 12:41:28 -0500
Received: from usnavsmail3.ndc.alcatel-lucent.com (usnavsmail3.ndc.alcatel-lucent.com [135.3.39.11])
	by ihemail4.lucent.com (8.13.8/IER-o) with ESMTP id pAGHfOog004037
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 11:41:24 -0600 (CST)
Received: from USNAVSXCHHUB02.ndc.alcatel-lucent.com (usnavsxchhub02.ndc.alcatel-lucent.com [135.3.39.111])
	by usnavsmail3.ndc.alcatel-lucent.com (8.14.3/8.14.3/GMO) with ESMTP id pAGHfO2X019485
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 11:41:24 -0600
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: Cloutier, Joseph (Joseph) 
Sent: Thursday, October 20, 2011 1:45 PM
To: 'netdev@vger.kernel.org'
Subject: How do I get bug fix for ping in iputils?

netdev-  alpha645 gave me your name from linux/questions.  Here is the issue.

There is a bug with the Linux flood ping option in iputils. *I have fixed this in my private code, but I would like to see it fixed in the official Linux iputils release.

Specifically, the "-w deadline" option is supposed to keep ping running after "-c count" pings have been transmitted as a grace period for the ping-responses to return and be counted. It is not working. The transmitted "-c count" appears to be ignored and pings keep being issued after the "-c count" option is met. This defeats the purpose of "-w deadline".

How do I file a bug report and get it followed up?
I fixed this a long time ago by setting a 2-second sleep and alarm call in the ping code.  Then kept ping running without issueing more pings after "-c count".
If you are the owner, I volunteer to port the fix to the latest code, test it, and send it back to you for vetting.
Thanks, Joe Cloutier jcloutier@alcatel-lucent.com
PS- flood ping is an invaluable tool for trouble shooting physical layer problems.
