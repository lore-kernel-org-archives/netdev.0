From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 0/4] cxgb3: driver fixes
Date: Fri, 17 Apr 2009 15:21:06 -0700
Message-ID: <49E900D2.3040700@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7088 "EHLO
	stargate.chelsio.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752127AbZDQXD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 19:03:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I am submitting a series of 4 patches for inclusion in 2.6.30.
Here is a brief description of the patch series:
- Use the existing periodic task to treat link faults, fix spin lock usage
- Fix missing workqueue flushes when the driver is unloaded
- Fix potential MSI-X vector leak on error case
- Fix EEH last recover attempt exit

Cheers,
Divy
