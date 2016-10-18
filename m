From: Timur Tabi <timur@codeaurora.org>
Subject: Need help parsing dropwatch results
Date: Tue, 18 Oct 2016 18:57:24 -0500
Message-ID: <5806B6E4.1050004@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55422 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754907AbcJRX50 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 19:57:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using iperf3 and dropwatch, I discovered that my EMAC driver is dropping 
packets, a lot of them.  This driver is based on an internal version 
(written by someone else) that does not have this problem, so obviously 
there's a bug in my driver.  Unfortunately, I need help understanding 
where in my driver the bug could be.

dropwatch display this:

3297 drops at net_tx_action+0 (0xffff000008aa1108)
3671 drops at net_tx_action+0 (0xffff000008aa1108)
4055 drops at net_tx_action+0 (0xffff000008aa1108)
3976 drops at net_tx_action+0 (0xffff000008aa1108)
3847 drops at net_tx_action+0 (0xffff000008aa1108)
3933 drops at net_tx_action+0 (0xffff000008aa1108)
3933 drops at net_tx_action+0 (0xffff000008aa1108)
1376 drops at net_tx_action+0 (0xffff000008aa1108)

Can someone tell me what "drops at net_tx_action+0" actually means? How 
does a packet drop at net_tx_action() actually occur?  Where in the 
driver should I look for the problem?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
