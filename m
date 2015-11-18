From: Lorenzo Colitti <lorenzo@google.com>
Subject: Support SOCK_DESTROY in ss
Date: Wed, 18 Nov 2015 10:52:08 +0900
Message-ID: <1447811530-10756-1-git-send-email-lorenzo@google.com>
Cc: edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:32932 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944AbbKRBwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 20:52:25 -0500
Received: by pabfh17 with SMTP id fh17so28050414pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 17:52:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds ss support for the SOCK_DESTROY operation just
submitted to net-next: http://patchwork.ozlabs.org/patch/545843/ .
It allows a user with CAP_NET_ADMIN to close sockets using
"ss --kill".
