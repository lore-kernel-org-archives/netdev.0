From: "Ray Lee" <ray@madrabbit.org>
Subject: Regression: Wireshark sees no packets in 2.6.24-rc3
Date: Thu, 13 Dec 2007 17:46:24 -0800
Message-ID: <2c0942db0712131746s7da91f2bkf45b3e1ddf16d1f3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:44696 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbXLNBq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 20:46:26 -0500
Received: by nf-out-0910.google.com with SMTP id g13so754368nfb.21
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 17:46:24 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tshark -i eth0, eth1, lo are all empty. Works under 2.6.23.0 just
fine. A quick scan of the log between 2.6.24-rc3 and current tip
(-rc5) doesn't show any obvious fixes, but then again, what do I know.
I'll check current tip on the weekend when I'll have the luxury to
have my main system down long enough for a test. Right now I'm kinda
up against a deadline, but didn't want to leave it unreported. Should
be easy for someone else to confirm or deny whether current tip has
the problem.

Ray
