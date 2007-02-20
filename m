From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 07:49:11 -0800
Message-ID: <f2b55d220702200749l4fa2b14foa861cf37288cfb8d@mail.gmail.com>
References: <200702191913.08125.dada1@cosmosbay.com>
	 <20070220092523.GA6238@2ka.mipt.ru>
	 <200702201104.16200.dada1@cosmosbay.com>
	 <20070220.021209.39159087.davem@davemloft.net>
	 <f2b55d220702200707t605be092hf02a9ded1c98a264@mail.gmail.com>
	 <20070220151119.GA17326@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, dada1@cosmosbay.com,
	akepner@sgi.com, linux@horizon.com, netdev@vger.kernel.org,
	bcrl@kvack.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:15818 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965175AbXBTPto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 10:49:44 -0500
Received: by an-out-0708.google.com with SMTP id b33so382438ana
        for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 07:49:43 -0800 (PST)
In-Reply-To: <20070220151119.GA17326@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/20/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Jenkins _does_ have them, I showed tests half a year ago and in this
> thread too. Actually _any_ hash has them it is just a matter of time
> to find one.

I think you misunderstood me.  If you are trying to DoS me from
outside with a hash collision attack, you are trying to feed me
packets that fall into the same hash bucket.  The Jenkins hash does
not have to be artifact-free, and does not have to be
cryptographically strong.  It just has to do a passable job of mixing
a random salt into the tuple, so you don't know which string of
packets to feed me in order to fill one (or a few) of my buckets.
XORing salt into a folded tuple doesn't help; it just permutes the
buckets.

Cheers,
- Michael
