From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 09:33:20 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52044F8F22@orsmsx418.amr.corp.intel.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com> <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com> <47A1E553.8010006@aei.mpg.de> <36D9DB17C6DE9E40B059440DB8D95F52044F8EC9@orsmsx418.amr.corp.intel.com> <47A204E5.7060406@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Bruce Allen" <ballen@gravity.phys.uwm.edu>,
	<netdev@vger.kernel.org>,
	"Henning Fehrmann" <henning.fehrmann@aei.mpg.de>,
	"Bruce Allen" <bruce.allen@aei.mpg.de>
To: "Carsten Aulbert" <carsten.aulbert@aei.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52390 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757914AbYAaRoV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:44:21 -0500
Content-class: urn:content-classes:message
In-Reply-To: <47A204E5.7060406@aei.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Carsten Aulbert wrote:
> PS: Am I right that the TCP_RR tests should only be run on a single
> node at a time, not on both ends simultaneously?

yes, they are a request/response test, and so perform the bidirectional
test with a single node starting the test.
