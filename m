From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH v2] iw_cxgb3: Support "iwarp-only" interfaces to avoid 4-tuple conflicts.
Date: Fri, 14 Sep 2007 09:06:56 -0700
Message-ID: <ada4phxkz8f.fsf@cisco.com>
References: <20070913191617.30937.95960.stgit@dell3.ogc.int>
	<20070914130941.GG18517@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise@opengridcomputing.com>, sean.hefty@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:5382 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755246AbXINQG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 12:06:58 -0400
In-Reply-To: <20070914130941.GG18517@2ka.mipt.ru> (Evgeniy Polyakov's message of "Fri, 14 Sep 2007 17:09:41 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Maybe you should automatically create an alias each time new interface
 > is added so that admin would not care about proper aliases?

I agree that makes much more sense from a user interface point of
view.  Unfortunately an alias without an address doesn't make sense,
so there doesn't seem to be a way to implement that.

 - R.
