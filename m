From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH 0/4 net-next] another transmit timestamping driver set
Date: Fri, 27 Apr 2012 15:04:03 -0400
Message-ID: <1335553447-11964-1-git-send-email-willemb@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirscher@intel.com, eilong@broadcom.com,
	aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f74.google.com ([209.85.213.74]:47860 "EHLO
	mail-yw0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820Ab2D0TEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 15:04:09 -0400
Received: by yhgm50 with SMTP id m50so118088yhg.1
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 12:04:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds skb_tx_timestamp calls into the ndo_start_xmit
implementations of a few more drivers. All calls are added before
increasing the txqueue write offset, to avoid the race conditions
with the completion handler experienced earlier.

All changes have been tested with the txtimestamp test at
http://kernel.googlecode.com/files/txtimestamp.c before and after
applying the change (to a slightly different kernel, though) to
verify that it actually adds the missing functionality and
introduces no obvious bugs.

Apologies if I missed any driver maintainers.

Signed-off-by Willem de Bruijn <willemb@google.com>
