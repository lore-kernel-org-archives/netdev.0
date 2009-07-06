From: Michael Guntsche <mike@it-loops.com>
Subject: Re: BUG: scheduling while atomic
Date: Mon, 6 Jul 2009 20:37:56 +0200
Message-ID: <23E5FE2E-C893-4606-A2B7-07ACF0A7A0BE@it-loops.com>
References: <23AED400-6DA5-462F-94F0-BEE34AC08A7A@it-loops.com> <20090627140643.7140f6a9@lxorguk.ukuu.org.uk> <33C7D336-F062-47B3-9033-D3DC465F793C@it-loops.com> <20090706074333.GA17276@gondor.apana.org.au> <20090706083119.GA17782@gondor.apana.org.au> <20090706163239.3f557b45@lxorguk.ukuu.org.uk> <20090706181736.766b3e7c@lxorguk.ukuu.org.uk> <6BC3DACB-2179-4322-B270-475180CC8AA2@it-loops.com> <20090706191852.3e138fc5@lxorguk.ukuu.org.uk>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:46549
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752126AbZGFShz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 14:37:55 -0400
In-Reply-To: <20090706191852.3e138fc5@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jul 6, 2009, at 20:18, Alan Cox wrote:

> On Mon, 6 Jul 2009 20:07:34 +0200
> Michael Guntsche <mike@it-loops.com> wrote:
>
>>
>> On Jul 6, 2009, at 19:17, Alan Cox wrote:
>>
>>> This is the more drastic way of doing it. I had hoped to put this
>>> off but
>>> in fact it cleans stuff up enormously. This has had only basic  
>>> testing
>>> but the underlying idea is to simply remove all the pty special  
>>> casing
>>> that causes messes in the first place.
>> <snip>
>>
>> Hi Alan,
>>
>> Must commit a6540f731d506d9e82444cf0020e716613d4c46c still be  
>> reverted
>> with your patch or can it stay in?
>
> Herbert is (as usual ;)) correct that it should be reverted.

No crashes with the reverted commit and Alan's patch on my hardware  
here.
A Load Test that would trigger it after some seconds is now running  
for several minutes without any problems.

Michael
