From: Ben Greear <greearb@candelatech.com>
Subject: Re: Ideas on why using WPA2 encryption speeds up many TCP connections?
Date: Thu, 03 Oct 2013 16:19:55 -0700
Message-ID: <524DFB9B.7010205@candelatech.com>
References: <524DB6F6.6020405@candelatech.com> <524DBC93.1070400@hp.com> <524DC2B8.905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48429 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216Ab3JCXUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 19:20:03 -0400
In-Reply-To: <524DC2B8.905@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was seeing an un-expectedly bad wifi train rates, so I changed to ath9k-rate-control,
rebooted, and re-ran the tests.  Throughput is much improved.  I really hope it wasn't just
a reboot that fixed it, but too burned out to do more tests today.

I still see better TCP throughput with WPA2 when using 25-200 stations/streams.

For anyone who wants to wade through some big automated reports, see the links
near the top of this page (suggestions for improving those reports are welcome):

http://www.candelatech.com/lf_wifi_examples.php

(The 600 station reports are a bit dated and were done in a fairly busy
  wifi environment.  We'll re-run those sometime soon-ish.)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
