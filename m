From: jamal <hadi@cyberus.ca>
Subject: [PATCH 0/3] pfkey/xfrm SAD/SPD flushing fixes
Date: Fri, 19 Feb 2010 07:00:39 -0500
Message-ID: <1266580842-10608-1-git-send-email-hadi@cyberus.ca>
References: <flush-fix-xfrm>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: davem@davemloft.net, adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:23182 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab0BSMA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 07:00:56 -0500
Received: by qw-out-2122.google.com with SMTP id 8so171666qwh.37
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 04:00:55 -0800 (PST)
In-Reply-To: <flush-fix-xfrm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

This patch set does split for pfkey response for flushing and 
makes sure events for flush are generated only when we have
a non-empty SAD/SPD. We maintain current behavior of silence
when a table is empty.

Jamal Hadi Salim (3):
  pfkey: fix SA and SP flush sequence
  xfrm: Flushing empty SAD generates false events
  xfrm: Flushing empty SPD generates false events

 net/key/af_key.c       |   37 ++++++++++++++++++++++++++++++++-----
 net/xfrm/xfrm_policy.c |   13 ++++++++++---
 net/xfrm/xfrm_state.c  |    8 ++++++--
 net/xfrm/xfrm_user.c   |   11 +++++++++--
 4 files changed, 57 insertions(+), 12 deletions(-)

