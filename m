From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] include listenq max/backlog in tcp_info and related	reports
 - correct version/signorder
Date: Mon, 17 Sep 2007 16:44:58 -0400
Message-ID: <46EEE74A.9090003@psc.edu>
References: <200709171950.MAA14825@tardy.cup.hp.com> <46EEDE35.8090102@psc.edu> <46EEE3D4.2070906@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:50093 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011AbXIQUpB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 16:45:01 -0400
In-Reply-To: <46EEE3D4.2070906@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> John Heffner wrote:
>> Any reason you're overloading tcpi_unacked and tcpi_sacked?  It seems 
>> that setting idiag_rqueue and idiag_wqueue are sufficient.
> 
> Different fields for different structures.   The tcp_info struct doesn't 
> have the idiag_mumble, so to get the two values shown in /proc/net/tcp I 
> use tcpi_unacked and tcpi_sacked.
> 
> For the INET_DIAG_INFO stuff the idiag_mumble fields are used and that 
> then covers ss.

Maybe I'm missing something.  get_tcp[46]_sock() does not use struct 
tcp_info.  The only way I see using this is by doing 
getsockopt(TCP_INFO) on your listen socket.  Is this the intention?

   -John

