From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/10] cxgb3: Chelsio T3 1G/10G ethernet device driver
Date: Thu, 07 Dec 2006 19:25:35 -0800
Message-ID: <4578DB2F.4010204@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:18533 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1164392AbWLHD0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 22:26:12 -0500
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I resubmit the patch supporting the latest Chelsio T3 adapter.
It incorporates feedbacks from Stephen:
- per port data accessed through netdev_priv()
- remove locking in netpoll() method

It also adapts to the new workqueue rules.

This patch adds support for the latest Chelsio adapter, T3. It is built
against 2.6.19.

A corresponding monolithic patch against 2.6.19 is posted at the
following URL: http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

We wish this patch to be considered for inclusion in 2.6.20. This driver
is required by the Chelsio T3 RDMA driver which was updated on 12/02/2006.

Cheers,
Divy

