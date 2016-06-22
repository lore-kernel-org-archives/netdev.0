From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 0/3] ss: Add support to filter by device
Date: Tue, 21 Jun 2016 20:38:23 -0700
Message-ID: <1466566706-1511-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35231 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbcFVDii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 23:38:38 -0400
Received: by mail-pa0-f41.google.com with SMTP id hl6so12398519pac.2
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 20:38:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for specifying device name in the filter to ss.
The kernel does not provide support for iface filtering, so if
the user specifies 'dev == NAME' or 'dev != NAME' all filtering
is done in userspace.

I will send a patch to add support for iface filtering in the kernel,
but the reality is that ss will need to accommodate both (ie., lack of
kernel support) for some time - which this set provides.

David Ahern (3):
  ss: Refactor inet_show_sock
  ss: Allow ssfilter_bytecompile to return 0
  ss: Add support to filter on device

 misc/ss.c       | 152 +++++++++++++++++++++++++++++++++++++++++---------------
 misc/ssfilter.h |   2 +
 misc/ssfilter.y |  22 +++++++-
 3 files changed, 135 insertions(+), 41 deletions(-)

-- 
2.1.4
