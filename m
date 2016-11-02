From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH net-next iproute2 0/2 v2] Add support for operating raw sockest via diag interface
Date: Wed,  2 Nov 2016 16:14:54 +0300
Message-ID: <1478092496-7540-1-git-send-email-gorcunov@gmail.com>
Cc: stephen@networkplumber.org, avagin@openvz.org,
        Cyrill Gorcunov <gorcunov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35322 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752839AbcKBNPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 09:15:04 -0400
Received: by mail-lf0-f67.google.com with SMTP id p100so962739lfg.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 06:15:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The diag interface for raw sockets is now in linux-net-next
http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=432490f9d455fb842d70219f22d9d2c812371676
so here is early patches for misc/ss

I've to update libnetlink code to keep backward compatibility and switch to
parse procfs output if no raw_diag module present in the system. Note the error
reporting sitting in the kernel since 2006 so it's not something new, I guess
this hasn't been done for other diag modules because it been assumed that they
are always here. Which is not applied to fresh raw-diag module.

	Cyrill
-- 
2.7.4
