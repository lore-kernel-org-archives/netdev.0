From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH v2] fm10k: Report MAC address on
 driver	load
Date: Wed, 2 Sep 2015 02:01:05 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E271B5392@ORSMSX103.amr.corp.intel.com>
References: <20150619023812.1345.75383.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:32114 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752061AbbIBCBG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 22:01:06 -0400
In-Reply-To: <20150619023812.1345.75383.stgit@ahduyck-vm-fedora22>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Alexander Duyck
Sent: Thursday, June 18, 2015 7:41 PM
To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
Subject: [Intel-wired-lan] [PATCH v2] fm10k: Report MAC address on driver load

This change adds the MAC address to the list of values recorded on driver load.  The MAC address represents the serial number of the unit and allows us to track the value should a card be replaced in a system.

The log message should now be similar in output to that of ixgbe.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---

Tested-By: Krishneil Singh <krishneil.k.singh@intel.com>

_______________________________________________
Intel-wired-lan mailing list
Intel-wired-lan@lists.osuosl.org
http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
