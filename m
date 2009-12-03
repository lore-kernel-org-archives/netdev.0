From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 0/2] netxen: fix debug tools and some corner cases
Date: Wed,  2 Dec 2009 17:46:17 -0800
Message-ID: <1259804779-23091-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:15835 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752562AbZLCBqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 20:46:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi

 Sending you two patches.

 1) Fixes debug tools access: 
	When debug tools need to access resources in unmapped regions,
        map these on the fly in order to complete read/write request.

 2) This fixes failure cases of fimware recovery module and
    and some corner cases.

