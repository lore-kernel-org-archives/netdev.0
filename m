From: Steve Chen <schen@mvista.com>
Subject: possible kernel oops from user MSS
Date: Wed, 10 Nov 2010 07:24:51 -0600
Message-ID: <AANLkTimMDMb74-3E9vhFxZ5Dgeuk3HMzPZVjwCj+yFEJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:41191 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755892Ab0KJNY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 08:24:57 -0500
Received: by iwn10 with SMTP id 10so786459iwn.19
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 05:24:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

With commit f5fff5dc8a7a3f395b0525c02ba92c95d42b7390, a user program
can pass in TCP_MAXSEG of 12 (or TCPOLEN_TSTAMP_ALIGNED), and cause
kernel oops with division by 0
 in tcp_select_initial_window.  One way to prevent it is to change the
minimum value for TCP_MAXSEG in do_tcp_setsockopt from 8 to some value
over 12.  Two questions.

1.  Is this the right solution?
2.  If it is, what is a good minimum value?

Thanks,

Steve
