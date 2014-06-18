From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/6] A step closer to RFC 6458 compliancy
Date: Wed, 18 Jun 2014 08:42:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725E555@AcuExch.aculab.com>
References: <1403017296-28469-1-git-send-email-geirola@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725DEC9@AcuExch.aculab.com>
 <53A08C10.70103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	'Geir Ola Vaagland' <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36209 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933182AbaFRInY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 04:43:24 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04276-09 for <netdev@vger.kernel.org>;
 Wed, 18 Jun 2014 09:43:15 +0100 (BST)
In-Reply-To: <53A08C10.70103@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich
> On 06/17/2014 11:36 AM, David Laight wrote:
> > From: Of Geir Ola Vaagland
> >> These patches are part of my master thesis project. I have been searching for discrepancies between
> >> the socket API specificiation in RFC 6458 and the current Linux SCTP implementation. The following
> >> patches are my humble attempts at getting somewhat closer to compliancy.
> >
> > I've just been reading RFC 6458 - HTF did it get past the editors and
> > then published in its current form?
> > Lots of the structures have implied padding.
...
> I've argued the padding issue, but the editor stance is that it's implementation
> dependent.

It wouldn't be as bad if the RFC said that the structure contained the
fields that followed (as is typical of the posix definitions),
but instead it gives a definition of the structure.

That isn't implementation friendly at all.

	David
