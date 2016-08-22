From: "Begun, Dennis" <dennis.begun@intel.com>
Subject: Callback at XFRM ESP tunnel creation
Date: Mon, 22 Aug 2016 09:14:55 +0000
Message-ID: <23722C679C74734A9D7EA99FFD01C40C26FFC7AC@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50921 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751754AbcHVJPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 05:15:16 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My goal is to run some code before actual packets begin running in the IPSec tunnel. For this, I am thinking of running a callback at the time of an XFRM ESP tunnel creation, where tunnel IPs and the SPI will be known. Is there a standard way of achieving this? If I'm not mistaken, registering for any event that has xfrm_state available should be enough, for instance, xfrm_add_sa, esp_init_state. 

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
