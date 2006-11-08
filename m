From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 0/3] labeled-ipsec: Repost patchset with updates [Originally:
 mlsxfrm: Various Fixes]
Date: Wed, 08 Nov 2006 17:03:29 -0600
Message-ID: <45526241.10805@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:45074 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1423875AbWKHXDu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 18:03:50 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset is against davem's net-2.6.git. Please apply to 2.6.19.

The following are the changes since the previous post of this patchset:

1. Separate BUG_ON usage per Eric's suggestion.

2. Replace security_sid_compare with a simple sid compare check per
   a suggestion from Paul/Stephen.
