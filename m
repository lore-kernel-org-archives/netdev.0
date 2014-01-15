From: Stephen Hemminger <stephen@networkplumber.org>
Subject: i40e sym version file
Date: Wed, 15 Jan 2014 08:16:45 -0800
Message-ID: <20140115081645.484c124d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:48242 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaAOQQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 11:16:50 -0500
Received: by mail-pd0-f173.google.com with SMTP id p10so1317189pdj.4
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 08:16:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The latest pull from Intel added a file to net-next git repo which is not
supposed to be part of build, it is a derived file:
 create mode 100644 drivers/net/ethernet/intel/i40e/Module.symvers


bad commit was
commit 9d8bf54723e9f21c502a410495840d8771f769ef
Author: Shannon Nelson <shannon.nelson@intel.com>
Date:   Tue Jan 14 00:49:50 2014 -0800

    i40e: associate VMDq queue with VM type
    
    Fix a bug where the queue was not associated with the right set-up
    within the hardware.  The fix is to use the right QTX_CTL VSI type
    when associating it to the VSI.
    
    Change-ID: I65ef6c5a8205601c640a6593e4b7e78d6ba45545
    Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
    Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
    Tested-by: Sibai Li <sibai.li@intel.com>
    Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
