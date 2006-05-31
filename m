From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/7] AMSO1100 Makefiles and Kconfig changes.
Date: Wed, 31 May 2006 13:36:44 -0700
Message-ID: <ada8xoix76r.fsf@cisco.com>
References: <20060531182733.3652.54755.stgit@stevo-desktop>
	<20060531182735.3652.44197.stgit@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mshefty@ichips.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:15267 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S964914AbWEaUgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 16:36:47 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <20060531182735.3652.44197.stgit@stevo-desktop> (Steve Wise's message of "Wed, 31 May 2006 13:27:35 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Can you reorder things so these changes go last?  Otherwise after this
patch we're left with a kernel tree that has a Makefile that refers to
sources that don't exist yet.  It's not really a practical issue but
it is neater to do that way.

(It's easy to do in stgit -- just pop all the patches and then use
"stg push <name>" to push them in a different order)

 - R.
