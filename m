From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Wed, 21 Oct 2015 10:25:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBBD206@AcuExch.aculab.com>
References: <20151019095938.72ea48e6@xeon-e3>
	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562594E1.8040403@oracle.com>
	 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56261092.7080003@oracle.com>
	 <1445347173.22974.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56264596.90104@oracle.com>
 <1445355027.22974.22.camel@edumazet-glaptop2.roam.corp.google.com>
 <5626887D.5050308@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Alan Burlison' <Alan.Burlison@oracle.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:64287 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbbJUKZp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 06:25:45 -0400
In-Reply-To: <5626887D.5050308@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Burlison
> Sent: 20 October 2015 19:31
...
> The problem with poll() is that it returns immediately when passed a FD
> that is in the listening state. rather than waiting until there's an
> incoming connection to handle. As I said, that means you can't use
> poll() to multiplex between read/write/accept sockets.

That seems to work for me...

	David
