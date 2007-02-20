From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 12:09:59 -0800
Message-ID: <f2b55d220702201209m6d6a276fj75f3462cdf6daeb@mail.gmail.com>
References: <200702191913.08125.dada1@cosmosbay.com>
	 <200702201738.19590.dada1@cosmosbay.com>
	 <20070220165907.GB24930@2ka.mipt.ru>
	 <200702201820.27095.dada1@cosmosbay.com>
	 <20070220175550.GB26961@2ka.mipt.ru>
	 <20070220181217.GA3401@2ka.mipt.ru>
	 <f2b55d220702201113m12355e5ds584cede246d4728c@mail.gmail.com>
	 <20070220194409.GB5590@2ka.mipt.ru>
	 <f2b55d220702201203m2f188253h7f68d5be9a457f4a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"David Miller" <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:44650 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030388AbXBTUKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 15:10:01 -0500
Received: by wr-out-0506.google.com with SMTP id i21so1977512wra
        for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 12:10:00 -0800 (PST)
In-Reply-To: <f2b55d220702201203m2f188253h7f68d5be9a457f4a@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/20/07, Michael K. Edwards <medwards.linux@gmail.com> wrote:
> Correct.  That's called a "weak hash", and Jenkins is known to be a
> thoroughly weak hash.  That's why you never, ever use it without a
> salt, and you don't let an attacker inspect the hash output either.

Weak in a cryptographic sense, of course.  Excellent avalanche
behavior, though, which is what you care about in a salted hash.
http://en.wikipedia.org/wiki/Hash_table

I know nothing about data structures and algorithms except what I read
on the Internet.  But you'd be amazed what's on the Internet.

Cheers,
- Michael
