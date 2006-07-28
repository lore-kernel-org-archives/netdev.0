From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Debugging kernel lockups during network activity
Date: Fri, 28 Jul 2006 16:39:10 +0200
Message-ID: <44CA218E.6040502@o2.pl>
References: <20060727181943.GD23091@artsapartment.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:44702 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1161178AbWG1Oid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 10:38:33 -0400
Received: from [192.168.100.10] (bv170.internetdsl.tpnet.pl [80.53.205.170])
	by poczta.o2.pl (Postfix) with ESMTP id 4341E7480D8
	for <netdev@vger.kernel.org>; Fri, 28 Jul 2006 16:38:32 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <20060727181943.GD23091@artsapartment.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27-07-2006 20:19, Art Haas wrote:
> Hi.
> 
> I've got Fedora Rawhide running on a SMP PIII machine, and the latest
> kernels from Fedora have been locking up when I run 'yum update' to
> get the latest packages. I also experience lock-ups when I use
> Firefox to do some web browsing. Not all my network usage results in a
> lockup, however. I can usually do 'git pull' and update git itself or
> my copy of Linus' kernel tree without problems, as well as update my
> GCC repo with subversion and Mozilla with cvs. I realize that running
> Fedora Rawhide means when things break I can keep the pieces, so
> the lockups or other occasional issues are not unexpected.

I don't know the numbers of this kernels, but did you try 
linux-2.6.18-rc2.

It has some great patch to queue scheduler by Hubert Xu. I think 
it is some Gnu/miracle that it has been working (mostly) under 
heavy load without this patch.

But there are also other possibilities...

Jarek P.
