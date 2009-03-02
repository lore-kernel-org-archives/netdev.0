From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: Vlan interface nuisance
Date: Sun, 01 Mar 2009 23:15:16 -0800
Message-ID: <49AB8784.609@vyatta.com>
References: <20090302065007.GA16974@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	kaber@trash.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40723 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752261AbZCBHPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 02:15:08 -0500
In-Reply-To: <20090302065007.GA16974@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Stephen Hemminger <shemminger@vyatta.com> wrote:
>   
>> Subject: vlan: names should be consistent
>>
>> Vlan's created via netlink should be the same as vlan's created
>> via older interface. This patches changes is to be consistent.
>>
>> One could argue this is an API change (it changes behaviour of netlink
>> interface), but I argue this was a design bug when the netlink interface
>> to VLAN was added.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>     
>
> I don't see the point of this.  The new interface is available
> through ip(8) only, vconfig remains unchanged.  So the user is
> completely aware that the name may change as he's using a new
> command.
>
> In any case, ip(8) allows you to set the name to whatever you
> want at creation time.  So for those nostalgics you can still
> use ethX.Y through ip.
>
> Cheers,
>   
 Yes but their is no indication as to which interface was just created.
