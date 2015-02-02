From: John Eckersberg <jeckersb@redhat.com>
Subject: Per-connection tcp_retries2 and RFC 1122 compliance
Date: Mon, 02 Feb 2015 16:05:21 -0500
Message-ID: <87a90w10tq.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37362 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933412AbbBBVFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2015 16:05:25 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t12L5Pl8032494
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 2 Feb 2015 16:05:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

RFC 1122, section 4.2.3.5 "TCP Connection Failures", states:

  (d)  An application MUST be able to set the value for R2 for
       a particular connection.  For example, an interactive
       application might set R2 to "infinity," giving the user
       control over when to disconnect.

The R2 value referenced above is implemented as the tcp_retries2 sysctl.
However it seems that the only way to tune that value is via the global
sysctl knob.  In other words, there is no provided way to set it only
for a particular connection as RFC 1122 requires.

Could someone confirm that this is a legitimate bug/deficiency?  Or am I
just missing something?  If this is a real bug, I would be willing to
put a patch together to fix it although I will probably require some
handholding (this would be my first contribution to the kernel).

Thanks,
John
