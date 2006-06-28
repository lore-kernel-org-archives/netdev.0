From: Xiaolan Zhang <cxzhang@us.ibm.com>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec (with latest updates)
Date: Tue, 27 Jun 2006 22:45:06 -0400
Message-ID: <OFC88A8D19.89EA923E-ON8525719B.000F18E3-8525719B.000F1DC6@us.ibm.com>
References: <Pine.LNX.4.64.0606272213240.7100@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andrew Morton <akpm@osdl.org>, chrisw@osdl.org,
	Catherine Zhang <cxzhang@watson.ibm.com>, czhang.us@gmail.com,
	"David S. Miller" <davem@davemloft.net>,
	George Wilson <gcwilson@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	latten@austin.ibm.com, netdev@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Serge E Hallyn <sergeh@us.ibm.com>, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:34182 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1422935AbWF1CpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 22:45:25 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5S2j9gq011397
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 22:45:09 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5S2j9n4280782
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 22:45:09 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5S2j8jS029059
	for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 22:45:09 -0400
In-Reply-To: <Pine.LNX.4.64.0606272213240.7100@d.namei>
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Got it.  Will send a new patch soon.

Catherine

James Morris <jmorris@namei.org> wrote on 06/27/2006 10:13:48 PM:

> On Tue, 27 Jun 2006, Xiaolan Zhang wrote:
> 
> > > Just one more thing, we don't need to export this function now.
> > 
> > You mean moving it to security/selinux/hooks.c and making it static?
> 
> Yep.
> 
> > I think conceptually this is where it should reside -- auditing system 

> > might need it in the future, for example.
> 
> We can export it then.
> 
> 
> 
> - James
> -- 
> James Morris
> <jmorris@namei.org>

