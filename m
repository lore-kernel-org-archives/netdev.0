From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 07:07:16 -0800
Message-ID: <f2b55d220702200707t605be092hf02a9ded1c98a264@mail.gmail.com>
References: <200702191913.08125.dada1@cosmosbay.com>
	 <20070220092523.GA6238@2ka.mipt.ru>
	 <200702201104.16200.dada1@cosmosbay.com>
	 <20070220.021209.39159087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, johnpol@2ka.mipt.ru, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:2909 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964970AbXBTPHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 10:07:19 -0500
Received: by ug-out-1314.google.com with SMTP id 44so808339uga
        for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 07:07:18 -0800 (PST)
In-Reply-To: <20070220.021209.39159087.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/20/07, David Miller <davem@davemloft.net> wrote:
> Actually someone (I think it was Evgeniy in fact) made such
> comparisons and found in his studies that not only does the current
> ehash xor hash function distribute about as well as jenkins, it's
> significantly cheaper to calculate :-)

However, it's vulnerable to hash collision attacks, which the Jenkins
hash (used as a poor man's HMAC with a boot-time random salt) is not.
But if you don't care about DoS ....

Cheers,
- Michael
