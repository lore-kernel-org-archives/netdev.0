From: Michael Buesch <mb@bu3sch.de>
Subject: d80211 merge plans
Date: Wed, 9 Aug 2006 07:03:41 +0200
Message-ID: <200608090703.45651.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:54983
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030476AbWHIFEC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 01:04:02 -0400
To: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am wondering about d80211 mainline merge plans.

Short:
I would like to see a mainline merge of d80211 happening
as soon as possible (next feature merge window).

Long:
I, as one of the main maintainers of the bcm43xx driver, am
maintaining two different branches of the driver at the moment.
It's getting harder and harder, but it's still ok.
But: We are so --><-- close before another branch of the project
must happen. That would mean we would have to maintain four
different branches. I am certainly not going to do this.

One might wonder why we require yet another branch of the driver.
It's simple. Broadcom effectively branched their driver, too. The
new 4.x binary driver version has _many_ differences and does not
even support older chipsets. That makes it necessary for our open
source driver to branch, too. At least for several months. We don't
know, if we are going to branch forever, or if we are going to merge
them after some months when it's stabilized, yet.

To heavily reduce maintainance burden I would like to see d80211
going mainline as soon as possible, so that we can feature-freeze
the softmac port of bcm43xx and reduce maintainance to next to zero
there. So if people want freaky features, we simply point them
to the d80211 port, which would coexist in mainline.

d80211 in mainline would clearly marked as experimental, for sure.
Notes must be added for possibly breaking usermode interfaces.

-- 
Greetings Michael.
