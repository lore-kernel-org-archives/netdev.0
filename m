From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Question on TSO maximum segment sizes.
Date: Thu, 11 Oct 2007 16:27:14 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903C4407B@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27793 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751947AbXJKX1P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 19:27:15 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm having an issue with TSO right vs. hardware that can't take the
maximum segment size sent from the stack.  I've been told that the
maximum packet size that can be sent to the hardware today is 64k, but
my hardware can only take 32k in certain modes per queue due to hardware
limitations.  I have two questions regarding this: 1) where is this
value set in the TCP code, and 2) Is this something that can be
configured on the fly?  If the answer to 2 is no, I will try and put
something together to allow this to happen.

Thanks in advance,
 
PJ Waskiewicz
Intel Corporation
peter.p.waskiewicz.jr@intel.com
