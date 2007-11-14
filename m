From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.24 1/1]S2io: Support for add/delete/store/restore ethernet addresses
Date: Wed, 14 Nov 2007 15:57:23 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD770289BA74@nekter>
References: <20071114.120359.21994235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	<netdev@vger.kernel.org>, <jeff@garzik.org>,
	"support" <support@neterion.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:45935 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764945AbXKNU5Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 15:57:25 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071114.120359.21994235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Scheduling for the 2.6.25 merge window is fine. Curious - why did
you
> > have to remove the driver version? We use it to keep track of our
> > changes submitted.
> 
> Because it conflicted with the driver version bump you did
> for the MSI-X leak bug fix.

[Ram] The version numbers are different for the 2 patches. Was the MSI-X
leak bug fix applied prior to resubmission (we had swapped the version
numbers on the patches for resubmission).

[PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing MSI-X local entry
memories when vector allocation fails 
+#define DRV_VERSION "2.0.26.6"

[PATCH 2.6.24 1/1]S2io: Support for add/delete/store/restore ethernet
addresses 
+#define DRV_VERSION "2.0.26.7"

Ram
