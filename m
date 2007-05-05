From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: How to find I/F to destination
Date: Sat, 5 May 2007 13:13:19 +0400
Message-ID: <20070505091319.GA5742@2ka.mipt.ru>
References: <463B388D.806@trash.net> <20070504132934.GD2291@2ka.mipt.ru> <20070504131657.GA2291@2ka.mipt.ru> <20070504125438.GA5439@2ka.mipt.ru> <5484.1178282928@redhat.com> <5910.1178284095@redhat.com> <7884.1178285089@redhat.com> <11217.1178285625@redhat.com> <11567.1178286922@redhat.com> <463B3C36.9080602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Howells <dhowells@redhat.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46805 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754461AbXEEJNa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2007 05:13:30 -0400
Content-Disposition: inline
In-Reply-To: <463B3C36.9080602@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 03:59:18PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> >>You need dst_release(&rt->u.dst) here.
> > 
> > 
> > Thanks.  I think Evgeniy's code may be wrong then.  He ends with a
> > dst_clone(), which I think is superfluous.
> 
> 
> Yes, that looks wrong.

Main idea is to get a reference, and then clone it for each user.
Then each user drops its reference, and when system is not used anymore,
main reference is dropped too.

-- 
	Evgeniy Polyakov
