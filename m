From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH v3 5/8] thunderbolt: Communication with the ICM
 (firmware)
Date: Thu, 14 Jul 2016 18:59:54 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F92CD7E6C8@HASMSX110.ger.corp.intel.com>
References: <1468495702-7467-1-git-send-email-amir.jer.levy@intel.com>
 <1468495702-7467-6-git-send-email-amir.jer.levy@intel.com>
 <5B8DA87D05A7694D9FA63FD143655C1B54294E4A@hasmsx108.ger.corp.intel.com>
 <9B0331B6EBBD0E4684FBFAEDA55776F92CD7D05F@HASMSX110.ger.corp.intel.com>
 <E607265CB020454880711A6F96C05A03893CD910@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	thunderbolt-linux <thunderbolt-linux@intel.com>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"Rosen, Rami" <rami.rosen@intel.com>
To: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>,
	"Winkler, Tomas" <tomas.winkler@intel.com>,
	"andreas.noever@gmail.com" <andreas.noever@gmail.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2606 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbcGNTAA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 15:00:00 -0400
In-Reply-To: <E607265CB020454880711A6F96C05A03893CD910@hasmsx107.ger.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Amir,

>This patch is the communication with the FW.
>The network functionality is added in the next patches in the series 
>and with it, more messages from FW.
>Indeed this function always returns true in this patch, 
>but while writing it, I predicted that the network functionality will 
>use the send_event flag differently.
>You can see the documentation of send_event - currently unused in this patch.
>I don't see any harm that in this patch, this function will always return true,
>while applying the rest of the series will change it.

Ok, seems reasonable.

>The prototype of suspend is return int:
>http://lxr.free-electrons.com/source/include/linux/pm.h#L295

>The prototype of resume is return int:
>http://lxr.free-electrons.com/source/include/linux/pm.h#L295

You are right about this, I missed the macro invocation in your code, SET_SYSTEM_SLEEP_PM_OPS(nhi_suspend, nhi_resume),
apologies.

 Regards,
 Rami Rosen
 Intel Corporation
