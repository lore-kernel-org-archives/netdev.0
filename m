From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 18:11:19 +0300
Message-ID: <20070220151119.GA17326@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <20070220092523.GA6238@2ka.mipt.ru> <200702201104.16200.dada1@cosmosbay.com> <20070220.021209.39159087.davem@davemloft.net> <f2b55d220702200707t605be092hf02a9ded1c98a264@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	akepner@sgi.com, linux@horizon.com, netdev@vger.kernel.org,
	bcrl@kvack.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56799 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965026AbXBTPNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 10:13:20 -0500
Content-Disposition: inline
In-Reply-To: <f2b55d220702200707t605be092hf02a9ded1c98a264@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 07:07:16AM -0800, Michael K. Edwards (medwards.linux@gmail.com) wrote:
> On 2/20/07, David Miller <davem@davemloft.net> wrote:
> >Actually someone (I think it was Evgeniy in fact) made such
> >comparisons and found in his studies that not only does the current
> >ehash xor hash function distribute about as well as jenkins, it's
> >significantly cheaper to calculate :-)
> 
> However, it's vulnerable to hash collision attacks, which the Jenkins
> hash (used as a poor man's HMAC with a boot-time random salt) is not.
> But if you don't care about DoS ....

Jenkins _does_ have them, I showed tests half a year ago and in this
thread too. Actually _any_ hash has them it is just a matter of time 
to find one.

> Cheers,
> - Michael

-- 
	Evgeniy Polyakov
