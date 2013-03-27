From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [net-next PATCH] [RFC] net: add option to enable error queue
 packets waking select
Date: Wed, 27 Mar 2013 23:43:52 +0000
Message-ID: <CD78D1C2.17703%matthew.vick@intel.com>
References: <20130327220028.13267.89112.stgit@jekeller-hub.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Richard Cochran <richardcochran@gmail.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62262 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253Ab3C0Xnx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 19:43:53 -0400
In-Reply-To: <20130327220028.13267.89112.stgit@jekeller-hub.jf.intel.com>
Content-Language: en-US
Content-ID: <FE05C46ABB93BB489AA0D7B5387EB7B8@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>index 4ef3acb..c5d2e3a 100644
>--- a/include/uapi/asm-generic/socket.h
>+++ b/include/uapi/asm-generic/socket.h
>@@ -74,4 +74,6 @@
> 
> #define SO_LOCK_FILTER		44
> 
>+#define SO_SELECT_ERR_QUEUE	45
>+
> #endif /* __ASM_GENERIC_SOCKET_H */

Shouldn't this also go in the arch/*/include/uapi/asm/socket.h headers?
