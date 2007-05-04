From: Patrick McHardy <kaber@trash.net>
Subject: Re: How to find I/F to destination
Date: Fri, 04 May 2007 15:59:18 +0200
Message-ID: <463B3C36.9080602@trash.net>
References: <463B388D.806@trash.net>  <20070504132934.GD2291@2ka.mipt.ru> <20070504131657.GA2291@2ka.mipt.ru> <20070504125438.GA5439@2ka.mipt.ru> <5484.1178282928@redhat.com> <5910.1178284095@redhat.com> <7884.1178285089@redhat.com> <11217.1178285625@redhat.com> <11567.1178286922@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56083 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755311AbXEDN7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 09:59:42 -0400
In-Reply-To: <11567.1178286922@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells wrote:
> Patrick McHardy <kaber@trash.net> wrote:
> 
> 
>>htons()
> 
> 
> Blech.  Thanks.  Does it actually matter what ports are specified?


It matters when IPsec port selectors are used to find the correct
policy.

>>You need dst_release(&rt->u.dst) here.
> 
> 
> Thanks.  I think Evgeniy's code may be wrong then.  He ends with a
> dst_clone(), which I think is superfluous.


Yes, that looks wrong.
