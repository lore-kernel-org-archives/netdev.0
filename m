From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/6] A step closer to RFC 6458 compliancy
Date: Tue, 17 Jun 2014 15:36:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725DEC9@AcuExch.aculab.com>
References: <1403017296-28469-1-git-send-email-geirola@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Geir Ola Vaagland' <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53228 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933394AbaFQPht convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 11:37:49 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 05914-08 for <netdev@vger.kernel.org>;
 Tue, 17 Jun 2014 16:37:40 +0100 (BST)
In-Reply-To: <1403017296-28469-1-git-send-email-geirola@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Geir Ola Vaagland
> These patches are part of my master thesis project. I have been searching for discrepancies between
> the socket API specificiation in RFC 6458 and the current Linux SCTP implementation. The following
> patches are my humble attempts at getting somewhat closer to compliancy.

I've just been reading RFC 6458 - HTF did it get past the editors and
then published in its current form?
Lots of the structures have implied padding.
There is an embedded 'struct sockaddr_storage' in the middle of
one structure. In some OS this should never actually be instantiated.

Maybe the interface could have been changed in 2001, but not in 2011.

	David
