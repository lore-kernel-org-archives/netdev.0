From: Alex Dubov <oakad@yahoo.com>
Subject: Re: Bad TCP timestamps on non-PC platforms
Date: Sun, 9 Jan 2011 19:41:13 -0800 (PST)
Message-ID: <798351.95533.qm@web37603.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37603.mail.mud.yahoo.com ([209.191.87.86]:26624 "HELO
	web37603.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752151Ab1AJDlP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jan 2011 22:41:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > 
> > You dont give new informations ;)
> > 

Some additional information (my wireshark was not validating checksums, so
I missed the real culprit).

It so appears, that when timestamps are enabled on my dev board, TCP
checksum in SYN packet turns out to be incorrect. That's why those packets
are dropped by the remote side. When TCP timestamps are disabled, checksums
are correct.

Any ideas where this particular problem may originate?



      
