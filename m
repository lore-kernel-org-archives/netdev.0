From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/11] cxgb3 - driver updates
Date: Tue, 21 Aug 2007 20:45:04 -0700
Message-ID: <46CBB140.7060501@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:32472 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbXHVDqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 23:46:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

I'm resubmitting the last cxgb3 patch series against netdev-2.6#upstream,
minus the first patch that you already applied and the last patch.

Here is a brief description:
-       Modify max HW Rx coalescing size
-       Log SGE doorbell Fifo overflow
-       Use Tx immediate data for offload packets whenever possible
-       RDMA can get internal mem info to workaround HW issues
-       More validity checks on connection ids
-       Stop MAC when a fatal error is detected
-       Log HW serial number
-       Update internal mem operating mode
-       Update engine microcode management, version is now 1.1.0
-       Update FW management, version is now 4.6.0
-       Ignore some HW errors until the HW is initialized

Cheers,
Divy



