From: "Hector Herrera" <mail4hh@imagen.ca>
Subject: rt_cache leak 2.6.18
Date: Tue, 17 Feb 2009 17:23:55 -0800 (PST)
Message-ID: <3496.64.46.62.42.1234920235.squirrel@webmail.imagen.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.imagen.ca ([208.181.178.12]:50687 "EHLO mail2.imagen.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757225AbZBRBmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2009 20:42:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail2.imagen.ca (Postfix) with ESMTP id 49BAC1EF924A
	for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 17:24:01 -0800 (PST)
Received: from mail2.imagen.ca ([127.0.0.1])
	by localhost (mail2.imagen.ca [127.0.0.1]) (amavisd-new, port 10027)
	with ESMTP id GnZt5QWzotP6 for <netdev@vger.kernel.org>;
	Tue, 17 Feb 2009 17:23:55 -0800 (PST)
Received: from webmail.imagen.ca (mailout.lgisp.net [208.181.178.28])
	by mail2.imagen.ca (Postfix) with ESMTP id 5A6081EF9284
	for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 17:23:55 -0800 (PST)
References: In-Reply-To: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm debugging an rt_cache leak in 2.6.18 and I would like to view the
memory contents of the leaked memory slab with the hopes that if I knew
which routes are being leaked then I would know which network traffic to
collect to be able to reproduce the leak in a test environment.

I would appreciate any suggestions you could give me with regards to how
to go about doing this (searching google didn't turn out anything too
helpful).

Thank you,

Hector




