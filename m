From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [Intel-wired-lan] [net PATCH 2/3] fm10k: Fix handling of napi
 budget when multiple queues are enabled per vector
Date: Tue, 27 Oct 2015 17:06:04 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E27221380@ORSMSX103.amr.corp.intel.com>
References: <20150922213002.2774.37924.stgit@ahduyck-vm-fedora22>
 <20150922213535.2774.9863.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Alexander Duyck <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26432 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964977AbbJ0RIE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 13:08:04 -0400
In-Reply-To: <20150922213535.2774.9863.stgit@ahduyck-vm-fedora22>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Alexander Duyck
Sent: Tuesday, September 22, 2015 2:36 PM
To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
Subject: [Intel-wired-lan] [net PATCH 2/3] fm10k: Fix handling of napi budget when multiple queues are enabled per vector

This patch corrects an issue in which the polling routine would increase the budget for Rx to at least 1 per queue if multiple queues were present.
This would result in Rx packets being processed when the budget was 0 which is meant to indicate that no Rx can be handled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
