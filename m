From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] sctp: regression bug fixes
Date: Thu, 22 Jan 2009 17:36:04 -0500
Message-ID: <1232663768-4028-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:2085 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758597AbZAVWgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:36:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David

This is a set of bug fixes that address various regressions reported to
the sctp list as well and to me privately.

Here is the list:
    1) SCTP checksum produced wrong result on big endian arch.
    2) Sometimes SCTP connection would hang withtout transmitting anything.
       Sometimes it would fail to retrnasmit after the second loss.
    3) The accept code raced with input processing resulting in locking the
       wrong socket.

Please apply and push to stable.

Thank you
-vlad
