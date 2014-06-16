From: Ben Greear <greearb@candelatech.com>
Subject: How to load config info before loading firmware?
Date: Mon, 16 Jun 2014 09:02:11 -0700
Message-ID: <539F1503.7050602@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:33657 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834AbaFPQCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 12:02:12 -0400
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id 94D4040A79A
	for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 09:02:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It would be nice to be able to configure some info before
loading firmware on at least the ath10k NIC.  The problem is,
there is no debugfs available before loading firmware, ethtool
would at best require restarting the NIC/firmware, and loading
binary config blobs attached to firmware is unpleasant.

Module parameters are generally frowned upon and may be difficult
to implement properly if we have multiple NICs with different
desired configuration in a single machine.

Are there any suggestions on how to do this sort of config?

Any other drivers currently allowing such things?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
