From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [git pull] vfs.git network field-by-field copyin patches
Date: Fri, 14 Jul 2017 03:50:54 +0100
Message-ID: <20170714025054.GF13102@ZenIV.linux.org.uk>
References: <20170708182100.GR10672@ZenIV.linux.org.uk>
 <20170711.202514.815304234636661456.davem@davemloft.net>
 <20170714013750.GC13102@ZenIV.linux.org.uk>
 <20170713.193602.14448503583172802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35430 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752974AbdGNCu5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 22:50:57 -0400
Content-Disposition: inline
In-Reply-To: <20170713.193602.14448503583172802.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[My apologies for late pull requests - I hoped to be back to normal
connectivity by yesterday evening.  Spent the night sitting in Logan
instead...]

This part of misc.compat queue was held back for review from networking
folks and since davem has jus ACKed those...

The following changes since commit 0d0606060baefdb13d3d80dba1b4c816b0676e16:

  mqueue: move compat syscalls to native ones (2017-07-04 13:13:49 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git misc.compat

for you to fetch changes up to f8f8a727eab1c5b78c3703a461565b042979cc79:

  get_compat_bpf_fprog(): don't copyin field-by-field (2017-07-04 13:14:34 -0400)

----------------------------------------------------------------
Al Viro (3):
      copy_msghdr_from_user(): get rid of field-by-field copyin
      get_compat_msghdr(): get rid of field-by-field copyin
      get_compat_bpf_fprog(): don't copyin field-by-field

 net/compat.c | 49 +++++++++++++++++++++++--------------------------
 net/socket.c | 31 ++++++++++++++-----------------
 2 files changed, 37 insertions(+), 43 deletions(-)
