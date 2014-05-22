From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH ipsec-next 2/2] xfrm: configure policy hash table
 thresholds by /proc
Date: Thu, 22 May 2014 10:15:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724B7DA@AcuExch.aculab.com>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
 <1399902325-1788-3-git-send-email-christophe.gouault@6wind.com>
 <20140515083447.GC32371@secunet.com> <5379B591.6020001@6wind.com>
 <20140522100905.GH32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Steffen Klassert' <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35746 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754083AbaEVKPn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 06:15:43 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 19611-01 for <netdev@vger.kernel.org>;
 Thu, 22 May 2014 11:15:32 +0100 (BST)
In-Reply-To: <20140522100905.GH32371@secunet.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klassert
...
> > Exporting a userland API (here by /proc) enables a user or a daemon to
> > choose a strategy according to information the kernel does not
> > necessarily have, and enables to implement various (possibly complex)
> > policies.
> >
> 
> If we add a user API for the current lookup mechanism, we will stick
> with this because we can't change it anymore without breaking userspace.
> So I don't want to add one before we finally decided on a long term
> lookup mechanism for IPsec.

You could have a user API call to find the list of available mechanisms
as well as one that returns/sets the current one.
Then there is no actual requirement to continue to support any specific one.

	David
