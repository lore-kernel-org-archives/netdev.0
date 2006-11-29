From: paul.moore@hp.com
Subject: [PATCH 0/3] NetLabel: add the remaining CIPSO tag types from the IETF draft
Date: Wed, 29 Nov 2006 13:18:17 -0500
Message-ID: <20061129181817.505281000@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:52919 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S967518AbWK2S2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 13:28:54 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset consists of three patches that add support for the remaining two
tag types from the CIPSO draft specification, the enumerated and range tags.
The most significant part about adding these two tags is that NetLabel now has
the ability to represent more than 240 categories (limitation imposed by the
current restricted bitmap tag).

In addition, the first patch in the set converts NetLabel's contiguous char
string category bitmap stored in network friendly bit/byte order into a sparse
bitmap stored in host friendly bit/byte order.  While this change was not
required to support the new CIPSO tags, it should make life much easier as the
old category bitmap would have proven problematic as the number of usable
categories increases with the new tag types.  It also has a side effect of
making the LSM specific code much less ugly.

During testing I have not seen any regressions with this patchset; please
consider this for net-2.6.20.  Thanks.

--
paul moore
linux security @ hp
