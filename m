From: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC PATCH 0/2] dmaengine: preparation for raid acceleration
Date: Fri, 01 Jun 2007 17:17:49 -0700
Message-ID: <20070602001527.1707.58092.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	christopher.leech@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59696 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754141AbXFBARu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 20:17:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

The following two patches are part of the raid acceleration series I
would like to push for 2.6.23 consideration.  I am sending these two
separately for your review for the following reasons: the 'dmaengine'
core initially came in through netdev,  patch #2 makes changes to
net/dev/core.c, and lastly I have an ack on the raid changes but no ack
from the community on the i/oat and dmaengine changes.

      dmaengine: add base support for the async_tx api
      dmaengine: move channel management to the client

Regards,
Dan

the full series is available at:
git://lost.foo-projects.org/~dwillia2/git/iop md-accel-linus
 
