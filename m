From: "Ertman, DavidX M" <davidx.m.ertman@intel.com>
Subject: RE: [E1000-devel] i217-LM boot wreckage
Date: Fri, 21 Mar 2014 21:28:55 +0000
Message-ID: <2B0E3F215D1AB84DA946C8BEE234CCC9370CF6D9@ORSMSX101.amr.corp.intel.com>
References: <alpine.DEB.2.02.1403201332400.18573@ionos.tec.linutronix.de>
 <alpine.DEB.2.02.1403201431580.18573@ionos.tec.linutronix.de>
 <2B0E3F215D1AB84DA946C8BEE234CCC9370CEFE3@ORSMSX101.amr.corp.intel.com>
 <alpine.DEB.2.02.1403201724500.18573@ionos.tec.linutronix.de>
 <alpine.DEB.2.02.1403211534040.18573@ionos.tec.linutronix.de>
 <alpine.DEB.2.02.1403211551030.18573@ionos.tec.linutronix.de>
 <D38E8E86660E514AB505863C19C9287C73F87D2B@ORSMSX102.amr.corp.intel.com>
 <2B0E3F215D1AB84DA946C8BEE234CCC9370CF4AB@ORSMSX101.amr.corp.intel.com>
 <alpine.DEB.2.02.1403211657110.18573@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13274 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769AbaCUV25 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 17:28:57 -0400
In-Reply-To: <alpine.DEB.2.02.1403211657110.18573@ionos.tec.linutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have discovered the cause of this issue.  It is related to the change in the application of a Si errata workaround.

I will be working on grok'ing the total impact of this issue and writing up the patch over the weekend and will have something pushed into our internal queue early next week.

Thanks again for finding this issue

-----Original Message-----
From: Thomas Gleixner [mailto:tglx@linutronix.de] 
Sent: Friday, March 21, 2014 8:58 AM
To: Ertman, DavidX M
Cc: Ronciak, John; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
Subject: RE: [E1000-devel] i217-LM boot wreckage

On Fri, 21 Mar 2014, Ertman, DavidX M wrote:

> This has been reproduced here.  I am touching base with the person who 
> reproduced it and will be addressing this as a high priority.

Cool!

> Thanks for finding this.

Thanks for caring!

       tglx
