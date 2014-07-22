From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 3/3] net: sctp: Add support for MSG_MORE on
 SCTP
Date: Tue, 22 Jul 2014 16:46:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1727B4AA@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1727AF02@AcuExch.aculab.com>
 <53CE65B5.3090903@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1727B2A0@AcuExch.aculab.com>
 <53CE7B2A.90104@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1727B3E7@AcuExch.aculab.com>
 <53CE9379.4030500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"Linux Networking Development Mailing List" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47396 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755990AbaGVQrx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 12:47:53 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07890-06 for <netdev@vger.kernel.org>;
 Tue, 22 Jul 2014 17:47:44 +0100 (BST)
In-Reply-To: <53CE9379.4030500@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich ...
> > I'm not sure what would be needed to be done to cause queued send data to be
> > sent when SCTP_F_TX_MSG_MORE is cleared by close() or set/clear SCTP_NODELAY.
> > It is probably a simple call to the correct function.
> 
> OK. I'll try to come up with some code for this.

Thanks.

	David
