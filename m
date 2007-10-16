From: Eric Sandeen <sandeen@redhat.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Tue, 16 Oct 2007 09:33:15 -0500
Message-ID: <4714CBAB.4090601@redhat.com>
References: <E1IgWqn-0000iU-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Mack <dmack@juniper.net>, davej@redhat.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932506AbXJPOd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 10:33:29 -0400
In-Reply-To: <E1IgWqn-0000iU-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> David Mack <dmack@juniper.net> wrote:
>> If I understand the message Dave Jones sent yesterday, the patch you
>> mention *was* applied to the e100 driver in 2.6.23-6.fc8?
> 
> Nope, he applied a different one which doesn't have the crucial
> part to disable NAPI polls before registration.
> 
> Cheers,

Hm... running 2.6.23-6.fc8, I've been through 30+ reboot cycles without
a problem.  Before, I'd oops every 5 or so times I booted...

I now have another NIC in the box, disabled; I don't think that should
be affecting anything?

-Eric
