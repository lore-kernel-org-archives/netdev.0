From: "Rindjunsky, Ron" <ron.rindjunsky@intel.com>
Subject: RE: mac80211/wme.c: check-after-use
Date: Wed, 23 Apr 2008 13:20:35 +0300
Message-ID: <1879838866982C46A9CB3D56BA49ADEB04CCF8FB@hasmsx411.ger.corp.intel.com>
References: <20080423095101.GV28933@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Adrian Bunk" <bunk@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:44832 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751434AbYDWKbJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 06:31:09 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080423095101.GV28933@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The Coverity checker spotted the following check-after-use of the 
> 
>        u32 len = qdisc->q.qlen;    <------
>
>        if (!qdisc || !qdisc->dequeue)
>                return;

Yep, this is a left over, I'll fix it
Thanks
Ron

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

