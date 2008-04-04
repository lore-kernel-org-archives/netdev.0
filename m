From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Subject: Why is tcp_reno_min_cwnd() ssthresh/2?
Date: Thu, 3 Apr 2008 17:00:04 -0800
Message-ID: <aa7d2c6d0804031800r7d796b40oc011e684bcd2f0c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:47888 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355AbYDDBAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 21:00:38 -0400
Received: by py-out-1112.google.com with SMTP id u52so4907209pyb.10
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2008 18:00:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings all,

Apologies if this is a dumb question, but why does
tcp_reno_min_cwnd()  return  ssthresh/2?

Since   ssthresh <- snd_cwnd/2   on loss, this looks like it tries to
reduce  snd_cwnd  to 1/4 its value before a loss event, presumably
then slow-starting back to half of the original  snd_cwnd.

As Tom Quetchenbach pointed out, it is also odd that  omitting
min_cwnd()  from a congestion control module causes  ssthresh  to be
used, giving different results from using  tcp_reno_min_cwnd().

Thanks,
Lachlan

-- 
Lachlan Andrew  Dept of Computer Science, Caltech
1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
http://netlab.caltech.edu/lachlan
