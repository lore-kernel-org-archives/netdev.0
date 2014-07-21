From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] clean up sparse cast warning in do_ip_getsockopt
Date: Mon, 21 Jul 2014 08:54:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17279EB0@AcuExch.aculab.com>
References: <20140720113017.GA8878@gmail.com>
 <20140720.222246.722922848026554870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "jmorris@namei.org" <jmorris@namei.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
	"karoly.kemeny@gmail.com" <karoly.kemeny@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45871 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753256AbaGUIzS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 04:55:18 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12259-09 for <netdev@vger.kernel.org>;
 Mon, 21 Jul 2014 09:55:09 +0100 (BST)
In-Reply-To: <20140720.222246.722922848026554870.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> From: Karoly Kemeny <karoly.kemeny@gmail.com>
> Date: Sun, 20 Jul 2014 13:30:17 +0200
> 
> > There is a sparse warning because of the implicit pointer cast in
> > do_ip_getsockopt.
> >
> > Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>
> 
> Please format your subject line correctly, it should be of the form:
> 
> 	[PATCH] ${SUBSYSTEM}: Description.
> 
> Your's is missing the subsystem prefix, which in this case should
> be "ipv4: "
> 
> > -		msg.msg_control = optval;
> > +		msg.msg_control = (__force void*) optval;
> 
> Please put a space between "void" and "*" in the cast.

And remove the one after the ')' ?

	David
