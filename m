From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC Patch net-next] tcp: add a global sysctl to control TCP delayed ack
Date: Thu, 17 Jan 2013 13:25:12 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7113@saturn3.aculab.com>
References: <1358334345-28980-1-git-send-email-amwang@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7110@saturn3.aculab.com> <20130117123420.GA23639@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Cong Wang" <amwang@redhat.com>, <netdev@vger.kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Rick Jones" <rick.jones2@hp.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53367 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751183Ab3AQN1T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 08:27:19 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22524-02 for <netdev@vger.kernel.org>;
 Thu, 17 Jan 2013 13:27:11 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20130117123420.GA23639@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Not that I disagree with this fundamentally but we already
> have a socket option to enable the functionality. All this
> patch does is making the same functionality available to
> users that are not able to make modification on the
> application level.

My reading of TCP_QUICKACK documentation is that it is a request
to send an ack now - rather than permanently disable delayed acks.
Having to do an extra system call after every rcv() call
is rather OTT.

Or did you mean some other socket option?

	David
