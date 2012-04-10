From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 0/2] l2tp: l2tp_ip socket fixes
Date: Tue, 10 Apr 2012 11:10:41 +0100
Message-ID: <1334052643-10910-1-git-send-email-jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53107 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756126Ab2DJKLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 06:11:05 -0400
Received: from localhost.localdomain (jchapman.plus.com [80.229.30.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id E8F34A62043
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 11:10:57 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of small fixes for the l2tp_ip socket support. This is for
L2TPv3 IP link encapsulation.

[PATCH 1/2] l2tp: fix refcount leak in l2tp_ip sockets
[PATCH 2/2] l2tp: don't overwrite source address in l2tp_ip_bind()

 net/l2tp/l2tp_ip.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)
