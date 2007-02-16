From: "kalyan tejaswi" <kalyanatejaswi@gmail.com>
Subject: degradation in bridging performance of 5% in 2.6.20 when compared to 2.6.19
Date: Fri, 16 Feb 2007 11:56:29 +0530
Message-ID: <9dd3c65d0702152226h6bfc4e22q3f3b04d97d8da1fb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.239]:11035 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932655AbXBPG0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 01:26:30 -0500
Received: by qb-out-0506.google.com with SMTP id z8so241007qbc
        for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 22:26:29 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,
I have been comparing bridging performance for 2.6.20 and 2.6.19
kernels. The kenel configurations are identical for both the kernels.
I use D-Link cards (8139too driver) for the Malta 4Kc board.

The setup is:

netperf  client  <------->  malta 4Kc  <---------> netperf  server.

The throughput statistics (in 10^6 bits/second) are:

                    2.6.19          2.6.20
routing            30.2           30.16
bridging          32.35          30.81

I observe that there has been a degradation in bridging performance of
5% in 2.6.20 when compared to 2.6.19.

Has anyone observed similar behaviour?
Any inputs or suggestions are welcome.


Regards
Kalyan
