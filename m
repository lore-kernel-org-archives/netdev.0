From: David Howells <dhowells@redhat.com>
Subject: Re: How to find I/F to destination
Date: Fri, 04 May 2007 14:55:22 +0100
Message-ID: <11567.1178286922@redhat.com>
References: <463B388D.806@trash.net>  <20070504132934.GD2291@2ka.mipt.ru> <20070504131657.GA2291@2ka.mipt.ru> <20070504125438.GA5439@2ka.mipt.ru> <5484.1178282928@redhat.com> <5910.1178284095@redhat.com> <7884.1178285089@redhat.com> <11217.1178285625@redhat.com>
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44998 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755289AbXEDNz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 09:55:27 -0400
In-Reply-To: <463B388D.806@trash.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:

> htons()

Blech.  Thanks.  Does it actually matter what ports are specified?

> You need dst_release(&rt->u.dst) here.

Thanks.  I think Evgeniy's code may be wrong then.  He ends with a
dst_clone(), which I think is superfluous.

David
