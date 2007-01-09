From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 0/12] forcedeth optimizations
Date: Tue, 09 Jan 2007 13:29:45 -0500
Message-ID: <45A3DF19.9070907@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:1650 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932385AbXAIVXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 16:23:14 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches contains optimizations for the forcedeth driver that 
help reduce CPU utilization and increase throughput, especially for 
small packet sizes.

The main changes include ring accessing, tx locking, optimizing code 
branches, remove descriptor checks in data paths, reducing memory 
accesses, etc.

Please provide feedback and comments.
[Note that some patches might not have apparent benefits by themselves. 
Some patches are just stepping stones for following patches]

Thanks,
Ayaz

