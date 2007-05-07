From: Rick Jones <rick.jones2@hp.com>
Subject: smp_affinity, MSI-X and 2.6.21.1
Date: Mon, 07 May 2007 13:53:39 -0700
Message-ID: <463F91D3.3010000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:45841 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966557AbXEGUxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 16:53:41 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel11.hp.com (Postfix) with ESMTP id 539413411B
	for <netdev@vger.kernel.org>; Mon,  7 May 2007 13:53:40 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id NAA13597
	for <netdev@vger.kernel.org>; Mon, 7 May 2007 13:53:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks -

Is it a bug, or a feature that after changing a device's smp_affinity via echo 
"N" >> /proc/irq/M/smp_affinity that the new mask isn't visible via cat 
/proc/irq/M/smp_affinity until after actual interrupts are taken?

rick jones
