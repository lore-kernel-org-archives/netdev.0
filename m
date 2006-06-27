From: paul.moore@hp.com
Subject: [RFC 0/8] NetLabel: updated to use generic netlink
Date: Tue, 27 Jun 2006 18:56:31 -0400
Message-ID: <20060627225631.538814000@flek.zko.hp.com>
Cc: sgrubb@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:35990 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S932574AbWF0XAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 19:00:52 -0400
To: redhat-lspp@redhat.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An updated patch set with some small changes as well as one big one - NetLabel
now uses the generic netlink interface for it's kernel-userland communication
as opposed to it's own dedicated netlink type.  Needless to say this requires
an updated userland configuration tool, so for those of you running this patch
please grab version 0.14 (or later) of the netlabel_tools which can be found
here:

 * http://free.linux.hp.com/~pmoore/projects/linux_cipso

Thanks.

--
paul moore
linux security @ hp
