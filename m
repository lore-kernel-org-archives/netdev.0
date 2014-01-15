From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: i40e sym version file
Date: Wed, 15 Jan 2014 16:22:07 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418A1C521E@FMSMSX102.amr.corp.intel.com>
References: <20140115081645.484c124d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52742 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752498AbaAOQWM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 11:22:12 -0500
In-Reply-To: <20140115081645.484c124d@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ooo, ick, that shouldn't be there.  Jeff is on sabbatical and Aaron is covering, I'll work with Aaron to find what happened and get it straightened out.

Thanks,
sln

________________________________________
From: Stephen Hemminger [stephen@networkplumber.org]
Sent: Wednesday, January 15, 2014 8:16 AM
To: Nelson, Shannon; Kirsher, Jeffrey T; David Miller
Cc: netdev@vger.kernel.org
Subject: i40e sym version file

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