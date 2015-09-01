From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] sctp: support global vtag assochash and per
 endpoint s(d)port assochash table
Date: Tue, 1 Sep 2015 14:53:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB8B410@AcuExch.aculab.com>
References: <6d09d44f7972c5a5e458fc0eef98aa057896403d.1441043068.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "mleitner@redhat.com" <mleitner@redhat.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>
To: 'Xin Long' <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:60286 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368AbbIAOyS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 10:54:18 -0400
In-Reply-To: <6d09d44f7972c5a5e458fc0eef98aa057896403d.1441043068.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long
> Sent: 31 August 2015 18:44
>
> for telecom center, the usual case is that a server is connected by thousands
> of clients. but if the server with only one enpoint(udp style) use the same
> sport and dport to communicate with every clients, and every assoc in server
> will be hashed in the same chain of global assoc hashtable due to currently we
> choose dport and sport as the hash key.

I'm not sure the above is true...

Although a server might be connected to 1000s of clients, if the sctp
'application' is M3UA then it is very likely that the source and
destination ports for all the associations are all the same (2905).

An M3UA application might also be written to use a single socket
(eg: in order to reduce the number of fds and/or poll() list size).

	David
