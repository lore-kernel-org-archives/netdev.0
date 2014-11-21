From: cprasad@cse.iitm.ac.in
Subject: Clarification regarding TCP advertised window
Date: Fri, 21 Nov 2014 11:37:06 +0530 (IST)
Message-ID: <1768979683.134536.1416550026650.JavaMail.root@mail.cse.iitm.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iitmpg.iitm.ac.in ([203.199.213.28]:42081 "EHLO
	mail.cse.iitm.ac.in" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbaKUGIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 01:08:37 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.cse.iitm.ac.in (Postfix) with ESMTP id C9C26F7812D
	for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 11:37:12 +0530 (IST)
Received: from mail.cse.iitm.ac.in ([127.0.0.1])
	by localhost (mail.cse.iitm.ac.in [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id smBOVb8dOvI8 for <netdev@vger.kernel.org>;
	Fri, 21 Nov 2014 11:37:06 +0530 (IST)
Received: from mail.cse.iitm.ac.in (mail.cse.iitm.ac.in [10.6.5.215])
	by mail.cse.iitm.ac.in (Postfix) with ESMTP id B00DEF78136
	for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 11:37:06 +0530 (IST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I was looking at TCP packets on wireshark and I found that during a download the advertised window in an ack packet was exceeding the max value of tcp_rmem parameter. What could be the reason for that?

Thanks
