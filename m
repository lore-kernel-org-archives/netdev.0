From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] fm10k: Don't assume page fragments
 are	page size
Date: Wed, 2 Sep 2015 02:00:25 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E271B5379@ORSMSX103.amr.corp.intel.com>
References: <20150616184712.1966.44790.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:20999 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbbIBCA0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 22:00:26 -0400
In-Reply-To: <20150616184712.1966.44790.stgit@ahduyck-vm-fedora22>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Alexander Duyck
Sent: Tuesday, June 16, 2015 11:47 AM
To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
Subject: [Intel-wired-lan] [PATCH] fm10k: Don't assume page fragments are page size

This change pulls out the optimization that assumed that all fragments would be limited to page size.  That hasn't been the case for some time now and to assume this is incorrect as the TCP allocator can provide up to a 32K page fragment.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 
Tested-By: Krishneil Singh <krishneil.k.singh@intel.com>
_______________________________________________
Intel-wired-lan mailing list
Intel-wired-lan@lists.osuosl.org
http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
