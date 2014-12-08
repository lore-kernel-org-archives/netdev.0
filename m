From: "Ulrich Windl" <Ulrich.Windl@rz.uni-regensburg.de>
Subject: Q: need effective backlog for listen()
Date: Mon, 08 Dec 2014 13:51:05 +0100
Message-ID: <5485ACC9020000A100018394@gwsmtp1.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrzmta2.uni-regensburg.de ([194.94.155.52]:44334 "EHLO
	rrzmta2.uni-regensburg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231AbaLHNA1 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:1:1>);
	Mon, 8 Dec 2014 08:00:27 -0500
Received: from rrzmta2.uni-regensburg.de (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id B876B51D80
	for <netdev@vger.kernel.org>; Mon,  8 Dec 2014 13:51:07 +0100 (CET)
Received: from gwsmtp1.uni-regensburg.de (gwsmtp1.uni-regensburg.de [132.199.5.51])
	by rrzmta2.uni-regensburg.de (Postfix) with ESMTP id 79CED50C43
	for <netdev@vger.kernel.org>; Mon,  8 Dec 2014 13:51:06 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(not subscribed to the list, plese keep me on CC:)

Hi!

I have a problem I could not find the answer. I suspect the problem arises from Linux derivating from standard functionality...

I have written a server that should accept n TCP connections at most. I was expecting that the backlog parameter of listen will cause extra connection requests either
1) to be refused
or
2) to time out eventually

(The standard seems to say that extra connections are refused)

However none of the above see ms true. Even if my server delays accept()ing new connections, no client ever sees a "connection refused" or "connection timed out". Is there any chance to signal the client that no more connections are accepted at the moment?

Regards,
Ulrich Windl
