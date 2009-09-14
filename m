From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Mon, 14 Sep 2009 12:11:51 +0300
Message-ID: <20090914091151.GE14030@redhat.com>
References: <20090910125929.GA32593@redhat.com> <15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com> <20090914080923.GC14030@redhat.com> <4AADFC0A.30305@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750870AbZINJNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 05:13:38 -0400
Content-Disposition: inline
In-Reply-To: <4AADFC0A.30305@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2009 at 11:17:14AM +0300, Or Gerlitz wrote:
> Michael S. Tsirkin wrote:
>> On Mon, Sep 14, 2009 at 11:07:25AM +0300, Or Gerlitz wrote:
>>   
>>> vhost injects packets into physical device, what is the use case of vhost injecting packets into the host network stack?
>>>     
>> The case where the user requires bridging, typically.
>>   
> So you want to support a scheme where someone wants to attach vhost to a  
> bridge? why not just telling these users to just set their vhost on top  
> of veth couple, such that one veth device is added to a bridge as  
> interface and a vhost instance is tied to the other veth device?
>
>
> Or.

That's already possible. However virtualization users are familiar with
configuring the tun device, and tun has grown virtualization-specific
extensions, so I don't see a reason not to accomodate these uses.

-- 
MST
