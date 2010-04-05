From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Mon, 05 Apr 2010 18:25:55 +0200
Message-ID: <m21vetc1d8.fsf@igel.home>
References: <n2w412e6f7f1003312000o3a69802j120acd3946458517@mail.gmail.com>
	<20100401143805.1f83a161@notabene.brown>
	<x2j412e6f7f1003312116rd3b3ba96t31267545efe7660f@mail.gmail.com>
	<20100401.002319.236233308.davem@davemloft.net>
	<w2n412e6f7f1004050223j3e15df91tcdf133670c636a85@mail.gmail.com>
	<1270483012.4722.161.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, neilb@suse.de,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:44445 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755173Ab0DEQZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 12:25:58 -0400
In-Reply-To: <1270483012.4722.161.camel@edumazet-laptop> (Eric Dumazet's
	message of "Mon, 05 Apr 2010 17:56:52 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Solaris man page extract :
>
> "Datagram sockets can dissolve the association by connecting to a null
> address."
>
> What is a null address ? 
>
> 1) A null pointer ? 
> 2) a pointer to a zone, but length of this zone is 0
> 3) Or a pointer to a zone filled with NULL bytes ?

Btw., POSIX.1 has changed the description from "If address is a null
address for the protocol, the socket's peer address shall be reset" in
the 2004 edition to "If the sa_family member of address is AF_UNSPEC,
the socket's peer address shall be reset" in the 2009 edition.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
