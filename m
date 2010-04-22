From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 0/8]qlcnic: inter driver coexistence fixes
Date: Thu, 22 Apr 2010 05:51:34 -0700
Message-ID: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43588 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754575Ab0DVMvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 08:51:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
   Different class of drivers co-exist for CNA device, there is some
   minimal interaction that will be required amongst the drivers for 
   performing some device level operations. Operations such as 
   device initialization, device recovery and device diagnostics test,
   can potentially affect other function drivers.
 
   All these drivers should follow common protocol(IDC) to do such operation.

   Fixing qlcnic driver according to Inter driver coexistence.
   
   Sending series of 8 patches, please apply them in net-next.

-Amit 
