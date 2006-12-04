From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH  v2 03/13] Provider Methods and Data Structures
Date: Mon, 04 Dec 2006 08:45:30 -0800
Message-ID: <adaodqjip91.fsf@cisco.com>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int>
	<20061202224947.27014.59189.stgit@dell3.ogc.int>
	<1165147639.3233.211.camel@laptopd505.fenrus.org>
	<1165249706.32724.35.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:47190 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937122AbWLDQpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 11:45:45 -0500
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1165249706.32724.35.camel@stevo-desktop> (Steve Wise's message of "Mon, 04 Dec 2006 10:28:25 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Roland, I think at one time we were talking about changing the Core to
 > better handle this?  Either with attributes/capabilities that the low
 > level driver can set, or by set these method ptrs to NULL and the core
 > should handle it in the wrapper function...

Yes, it would make sense to change the midlayer so we have different
sets of mandatory functions for IB and iWARP drivers.  For example,
the iwcm functions probably should be mandatory for iWARP devices, right?

 - R.
