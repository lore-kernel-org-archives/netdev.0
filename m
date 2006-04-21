From: Zach Brown <zach.brown@oracle.com>
Subject: tune back idle cwnd closing?
Date: Fri, 21 Apr 2006 12:58:56 -0700
Message-ID: <44493980.1040708@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from tetsuo.zabbo.net ([207.173.201.20]:50074 "EHLO tetsuo.zabbo.net")
	by vger.kernel.org with ESMTP id S1751285AbWDUT7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 15:59:00 -0400
Received: from [127.0.0.1] (unknown [207.173.201.20])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by tetsuo.zabbo.net (Postfix) with ESMTP id C4F1A2FD0430
	for <netdev@vger.kernel.org>; Fri, 21 Apr 2006 12:58:59 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My apologies if this is a FAQ, I couldn't find it in the archives.

We have some dudes who are syncing large amounts of data across a
dedicated long fat pipe at somewhat irregular intervals that are, sadly,
longer than the rto.  They feel the pain of having to reopen the window
between transmissions.

Is there room for a compromise tunable that would be less aggressive
about closing cwnd during idle periods but which wouldn't violate the
spirit of 2861?  No one wants broken TCP here.

They mention that Solaris has the tcp_slow_start_after_idle tunable and
that it helps their situation.  I mention that only as a data point, I
wouldn't be foolish enough to try and use the presence of something in
Solaris as justification :)

- z
