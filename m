From: Andrew Morton <akpm@linux-foundation.org>
Subject: sctp use-uninitialized warning in net-2.6.25
Date: Wed, 16 Jan 2008 13:59:57 -0800
Message-ID: <20080116135957.4eb54958.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38347 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751484AbYAPV77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 16:59:59 -0500
Received: from imap1.linux-foundation.org (imap1.linux-foundation.org [207.189.120.55])
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id m0GLxvQo026975
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 13:59:58 -0800
Received: from akpm.corp.google.com (localhost [127.0.0.1])
	by imap1.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with SMTP id m0GLxvHr026327
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 13:59:57 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/sctp/sm_statefuns.c: In function 'sctp_sf_do_5_1C_ack':
net/sctp/sm_statefuns.c:484: warning: 'error' may be used uninitialized in this function

It is not obvious that this is a false positive.
