From: Timo Teras <timo.teras@iki.fi>
Subject: inet netconf support for send_redirects
Date: Wed, 6 May 2015 16:37:46 +0300
Message-ID: <20150506163746.38d75537@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:36168 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbbEFNjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 09:39:00 -0400
Received: by lagv1 with SMTP id v1so7573594lag.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 06:38:58 -0700 (PDT)
Received: from vostro ([2001:1bc8:101:f402:21a:9fff:fe0c:4022])
        by mx.google.com with ESMTPSA id si3sm375099lbb.32.2015.05.06.06.38.58
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 06:38:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm wondering if inet netconf support is planned or known will-not-add
for send_redirects (or the other missing proc/sys/ipv4/<if>/ knobs)?

I would be interested in this, and willing to implement it at least for
send_redirects. Mostly because I'd like an user-space routing daemon to
be able to control it, and run it as non-root. Now it's not possible
without dac-override capability to access proc/sys which sounds an
overkill for this purpose. Where as with netlink access the net-admin
capability is suit for the job.

Semi-relatedly, is there any specific reason why send_redirects is a
IN_DEV_ORCONF() option? Meaning that having the all/send_redirects set
to yes (the default) redirects are always sent. I would have thought
IN_DEV_ANDCONF() would make more sense in this case. Or is this just
some legacy thing?

Thanks,
Timo
