From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Mon, 14 Sep 2009 11:17:14 +0300
Message-ID: <4AADFC0A.30305@voltaire.com>
References: <20090910125929.GA32593@redhat.com>	<15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com> <20090914080923.GC14030@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:16125 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752996AbZINIR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 04:17:27 -0400
In-Reply-To: <20090914080923.GC14030@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael S. Tsirkin wrote:
> On Mon, Sep 14, 2009 at 11:07:25AM +0300, Or Gerlitz wrote:
>   
>> vhost injects packets into physical device, what is the use case of vhost injecting packets into the host network stack?
>>     
> The case where the user requires bridging, typically.
>   
So you want to support a scheme where someone wants to attach vhost to a 
bridge? why not just telling these users to just set their vhost on top 
of veth couple, such that one veth device is added to a bridge as 
interface and a vhost instance is tied to the other veth device?


Or.

