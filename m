From: Serge Goodenko <s_goodenko@mail.ru>
Subject: Question on using Linux as a router
Date: Fri, 21 Apr 2006 18:21:04 +0400
Message-ID: <E1FWwVM-000Jwr-00.s_goodenko-mail-ru@f64.mail.ru>
Reply-To: Serge Goodenko <s_goodenko@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from f64.mail.ru ([194.67.57.98]:33543 "EHLO f64.mail.ru")
	by vger.kernel.org with ESMTP id S932098AbWDUOVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 10:21:10 -0400
Received: from mail by f64.mail.ru with local
	id 1FWwVM-000Jwr-00
	for netdev@vger.kernel.org; Fri, 21 Apr 2006 18:21:04 +0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everybody!

I got the following question.

When I use linux as a router (via ip forwarding) what kernel variables (maybe some queues?) represent the closest analogue of usual hardware router input and output buffers? May this be, say, backlog queue or something else?

The things I need to get are the sizes and loads of that buffers during transmission.
I know about variables such as sk->sk_rcvbuf and sk->sk_rmem_alloc but they are not used during ip forwarding as the socket (i.e. sock structure) is not even being created for that purpose. As far as I understood these variables in sock structure are mostly used for tcp-level packet processing and they represent the values written in files like /proc/sys/net/core/wmem_default etc. (please correct me if that's wrong), but nevertheless maybe I also can use these values for "routing" buffers (i.e. on ip level)?

thanks in advance,
Servge
MIPT
Moscow, Russia
