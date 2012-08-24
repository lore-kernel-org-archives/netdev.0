From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: netlink scm creds uid and gids are always 0.
Date: Fri, 24 Aug 2012 10:45:17 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FC5@saturn3.aculab.com>
References: <871uiwlrf3.fsf@xmission.com><1345795065.5904.2287.camel@edumazet-glaptop><87txvsk8h7.fsf@xmission.com> <877gsok68x.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55503 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753718Ab2HXJ5v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 05:57:51 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01800-01 for <netdev@vger.kernel.org>;
 Fri, 24 Aug 2012 10:57:42 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <877gsok68x.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There is still a possible issue with netlink sockets and pids when the
> two processes talking over netlink are in different pid namespaces.

Isn't there a more general problem of the sending process exiting
and its pid being reused before the receiving program makes use
of the value?

IIRC 2.6.27 tried to alleviate this for some code paths by
using a reference-counted structure for some kernel calls.
(A PITA because the function to lose the reference is exported
GPL_ONLY ...)

	David
