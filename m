From: paul.moore@hp.com
Subject: [PATCH v2 0/1] Respun patch to match the latest secid patchset
Date: Mon, 02 Oct 2006 14:06:33 -0400
Message-ID: <20061002180633.639599000@hp.com>
Cc: jmorris@namei.org, sds@tycho.nsa.gov, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:34519 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S965230AbWJBSQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 14:16:35 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset is against the net-2.6 tree from this morning plus the secid
patches posted by Venkat yesterday night.  Unfortunately the net-2.6 trees from
the past few days seem to have problems booting on my test machine, so testing
of this patch has been ... well ... "minimal".  However, I know there are a lot
of deadlines floating around right now so I thought it best to post this ASAP.

This patch is basically what I posted last week plus some changes to make use
of the secid patches support of the peer_sid field in the sk_security_struct.
NetLabel used the field previously but had to special case it's handling since
it was the only user for INET sockets, the secid patchset makes this much
cleaner.  There are most likely additional NetLabel specific cleanups that can
be made, but considering my testing problems I thought it best to play it as
safe as possibile with this patch.  I'll deal with the other cleanups once I
can prove them during testing.

Please consider this for inclusion in 2.6.19.

--
paul moore
linux security @ hp
