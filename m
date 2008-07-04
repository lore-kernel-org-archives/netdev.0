From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: MD5 SG fix
Date: Thu, 3 Jul 2008 17:07:54 -0700
Message-ID: <396556a20807031707u26276f7dx8787f8b23d050087@mail.gmail.com>
References: <396556a20805301217k293e5718h6bbf02bfe0683152@europa>
	 <396556a20805301217k293e5718h6bbf02bfe0683153@europa>
	 <20080702045555.GB11252@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@vyatta.com>, netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:38029 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbYGDAHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 20:07:54 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1243867rvb.1
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2008 17:07:54 -0700 (PDT)
In-Reply-To: <20080702045555.GB11252@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 1, 2008 at 9:55 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Why dont't you want to iterate over all provided data/page pointers with
> crypto_hash_update() and do not mess with huge scatterlist arrays?

You're right, it's easier that way. I was just stuck in the thinking
of the original code.

Stephen: I managed to test the SG stuff by setting up lo in jumbo
frames mode, so no need to test it on your BGP stuff.


Cheers,

AGL


-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
