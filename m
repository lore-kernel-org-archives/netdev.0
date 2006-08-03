From: paul.moore@hp.com
Subject: [PATCH-v01 0/7] Latest NetLabel patchset against net-2.6.19
Date: Thu, 03 Aug 2006 16:09:28 -0400
Message-ID: <20060803200928.721027000@flek.zko.hp.com>
Cc: linda.knippers@hp.com, sds@tycho.nsa.gov, jmorris@namei.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:55432 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S932561AbWHCUP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 16:15:58 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the NetLabel patchset backed against DaveM's net-2.6.19 tree.  The
major changes from the last version have been the conversion to the new LSM
hooks that were introduced with the MLSXFRM patchset and the shift to using
Netlink attributes.  I've also done some work to reduce the amount of overhead
when categories are used.

Please consider this for inclusion into 2.6.19.

For those of you who are testing this patch, due to the shift to Netlink
attributes you will need to get the latest netlabel_tools package, version
0.16.  The netlabel_tools can be downloaded here:

 * http://free.linux.hp.com/~pmoore/projects/linux_cipso

Thanks.

--
paul moore
linux security @ hp
