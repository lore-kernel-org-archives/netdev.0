From: Patrick McHardy <kaber@trash.net>
Subject: Re: Vlan interface nuisance
Date: Mon, 02 Mar 2009 10:45:43 +0100
Message-ID: <49ABAAC7.6070806@trash.net>
References: <20090302073912.GA17328@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	shemminger@vyatta.com, davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40079 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195AbZCBJpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 04:45:47 -0500
In-Reply-To: <20090302073912.GA17328@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Stephen Hemminger <stephen.hemminger@vyatta.com> wrote:
>>> In any case, ip(8) allows you to set the name to whatever you
>>> want at creation time.  So for those nostalgics you can still
>>> use ethX.Y through ip.
>>>   
>> Yes but their is no indication as to which interface was just created.
> 
> You should be able to set the name at creation time.
> 
> The default is only used if you didn't specify an explicit name.

Indeed. The kernel also sends notifications, so iproute could print
the generated name if none was specified.
