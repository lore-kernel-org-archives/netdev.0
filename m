From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH 3/3] fm10k: use napi_schedule_irqoff()
Date: Tue, 27 Oct 2015 17:08:56 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E2722139C@ORSMSX103.amr.corp.intel.com>
References: <20150929215117.3388.48642.stgit@ahduyck-vm-fedora22>
 <20150929221956.3388.23153.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Alexander Duyck <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55733 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485AbbJ0RJ5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 13:09:57 -0400
In-Reply-To: <20150929221956.3388.23153.stgit@ahduyck-vm-fedora22>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Alexander Duyck
Sent: Tuesday, September 29, 2015 3:20 PM
To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
Subject: [Intel-wired-lan] [PATCH 3/3] fm10k: use napi_schedule_irqoff()

The fm10k_msix_clean_rings function runs from hard interrupt context or with interrupts already disabled in netpoll.

It can use napi_schedule_irqoff() instead of napi_schedule()

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
