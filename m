From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Kernel panic in inet_twdr_do_twkill_work
Date: Wed, 13 May 2009 18:22:46 -0700
Message-ID: <m17i0ktr4p.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Denis V. Lunev" <den@openvz.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42186 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752776AbZENBWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 21:22:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So far I have only seen this twice.  But the backtrace looks
almost identical to the one in commit d315492b1a6ba29da0fa2860759505ae1b2db857

The kernels I saw this on were patched version of 2.6.28 with some
network namespace backports.  commit
d315492b1a6ba29da0fa2860759505ae1b2db857 was definitely present.

Daniel any ideas?

Eric

