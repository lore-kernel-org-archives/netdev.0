From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: e1000e: Avoid wrong check on TX hang
Date: Wed, 21 Mar 2012 18:20:39 +0100
Message-ID: <OF66508452.5C6F589E-ONC12579C8.005ECBB5-C12579C8.005F4640@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-88.131.87.204.addr.tdcsong.se ([88.131.87.204]:38162
	"EHLO gw1.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758699Ab2CURbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 13:31:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I think commit 09357b00255c233705b1cf6d76a8d147340545b8(e1000e: Avoid wrong check on TX hang)
needs to be applied in 3.2.x (and 3.0.x) too.

We have seen this on routers(we got 3):
e1000e 0000:11:00.0: eth9: Detected Hardware Unit Hang:
  TDH                  <a4>
  TDT                  <a7>
  next_to_use          <a7>
  next_to_clean        <a4>
buffer_info[next_to_clean]:
  time_stamp           <1008e849f>
  next_to_watch        <a4>
  jiffies              <1008e85d8>
  next_to_watch.status <0>
MAC Status             <80387>
PHY Status             <792d>
PHY 1000BASE-T Status  <3800>
PHY Extended Status    <3000>
PCI Status             <10>

Applying the above patch on 3.2.12 makes the error go away.

   Jocke
