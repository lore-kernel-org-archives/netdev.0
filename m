From: john <john@potentialcash.com>
Subject: small bug in tcp
Date: Sat, 28 Jul 2007 19:07:05 +0300
Message-ID: <46AB69A9.2000003@potentialcash.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.potentialcash.com ([213.180.119.146]:49090 "EHLO
	mail.potentialcash.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227AbXG1QHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2007 12:07:34 -0400
Received: from [10.1.0.10] (unknown [10.1.0.10])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.potentialcash.com (Postfix) with ESMTP id 88494238C7
	for <netdev@vger.kernel.org>; Sat, 28 Jul 2007 19:07:21 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When application closes socket with unread data in receive buffer, tcp 
stack sends rst packet from the wrong source port, not the source port 
of the socket being closed.

This is the same problem that was described in my first post, witch 
unfortunately nobody cared to look into.

This problem appeared in 2.4.0-test9-pre3 and is still present in kernel.
