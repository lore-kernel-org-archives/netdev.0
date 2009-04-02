From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 18:00:17 +0300
Message-ID: <49D4D301.2090209@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <200904022243.21088.rusty@rustcorp.com.au> <49D4B4A3.5070008@novell.com> <49D4B87D.2000202@redhat.com> <20090402145018.GA816@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	Rusty Russell <rusty@rustcorp.com.au>, anthony@codemonkey.ws,
	andi@firstfloor.org, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53448 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762950AbZDBPAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 11:00:34 -0400
In-Reply-To: <20090402145018.GA816@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Apr 02, 2009 at 04:07:09PM +0300, Avi Kivity wrote:
>   
>> I think Rusty did mean a UP guest, and without schedule-and-forget.
>>     
>
> Going off on a tangent here, I don't really think it should matter
> whether we're UP or SMP.  The ideal state is where we have the
> same number of (virtual) TX queues as there are cores in the guest.
> On the host side we need the backend to run at least on a core
> that shares cache with the corresponding guest queue/core.  If
> that happens to be the same core as the guest core then it should
> work as well.
>
> IOW we should optimise it as if the host were UP.
>   

Good point - if we rely on having excess cores in the host, large guest 
scalability will drop.

-- 
error compiling committee.c: too many arguments to function

