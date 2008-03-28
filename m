From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [GIT PATCHES 0/4] SCTP fixes
Date: Fri, 28 Mar 2008 10:56:16 -0400
Message-ID: <1206716180-16573-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:20998 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758241AbYC1O4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 10:56:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

The following changes since commit 732c8bd590625e8bc0b88313b82930e336b2bec4:
  Herbert Xu (1):
        [IPSEC]: Fix BEET output

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git pending

You can pull the branch, or apply inidividual patches that follow this e-mail.

Gui Jianfeng (2):
      [SCTP]: Fix protocol violation when receiving an error lenght INIT-ACK
      [SCTP]: Remove an unused parameter from sctp_cmd_hb_timer_update

Robert P. J. Day (1):
      [SCTP]: "list_for_each()" -> "list_for_each_entry()" where appropriate.

Wei Yongjun (1):
      [SCTP]: Add check for hmac_algo parameter in sctp_verify_param()

 include/net/sctp/command.h |    1 +
 net/sctp/associola.c       |   34 +++++++++++---------------
 net/sctp/bind_addr.c       |   15 +++--------
 net/sctp/outqueue.c        |   52 +++++++++++++++--------------------------
 net/sctp/proc.c            |    9 ++----
 net/sctp/sm_make_chunk.c   |   39 +++++++++++++++++++++++-------
 net/sctp/sm_sideeffect.c   |   26 ++++++++-----------
 net/sctp/sm_statefuns.c    |   28 +++++++++++++++++----
 net/sctp/socket.c          |   56 +++++++++++++------------------------------

Thanks
-vlad
