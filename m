From: Felix von Leitner <felix-linuxkernel@fefe.de>
Subject: Re: bizarre network timing problem
Date: Fri, 2 Nov 2007 23:38:56 +0100
Message-ID: <20071102223856.GA5121@codeblau.de>
References: <20071017205127.GA21334@codeblau.de> <47167BDE.4000103@redhat.com> <20071017220019.GA22765@codeblau.de> <471689BF.2040909@hp.com> <20071018094230.GA2978@codeblau.de> <4717964A.8080100@hp.com> <20071102221146.GA4354@codeblau.de> <472BA5BC.6000901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Ebbert <cebbert@redhat.com>, linux-kernel@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ioctl.codeblau.de ([80.190.240.67]:46577 "EHLO codeblau.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752555AbXKBWi6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2007 18:38:58 -0400
Content-Disposition: inline
In-Reply-To: <472BA5BC.6000901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thus spake Rick Jones (rick.jones2@hp.com):
> >Oh I'm pretty sure it's not my application, because my application performs
> >well over ethernet, which is after all its purpose.  Also I see the
> >write, the TCP uncork, then a pause, and then the packet leaving.
> Well, a wise old engineer tried to teach me that the proper spelling is 
> ass-u-me :) so just for grins, you might try the TCP_RR test anyway :)  And 
> even if your application is correct (although I wonder why the receiver 
> isn't sucking data-out very quickly...) if you can reproduce the problem 
> with netperf it will be easier for others to do so.

My application is only the server, the receiver is smbget from Samba, so
I don't feel responsible for it :-)

Still, when run over Ethernet, it works fine without waiting for
timeouts to expire.

To reproduce this:

  - smbget is from samba, you probably already have this
  - gatling (my server) can be gotten from
    cvs -d :pserver:cvs@cvs.fefe.de:/cvs -z9 co dietlibc libowfat gatling

dietlibc is not strictly needed, but it's my environment.
First built dietlibc, then libowfat, then gatling.

Felix
