From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [tcpdump-workers] Modular arithmetic
Date: Mon, 10 Sep 2012 13:49:36 +0200
Message-ID: <CAD6jFUSPxPjtkNHBakuQpDS--uG2YTt+EAE-6Q+t473_t9A3sQ@mail.gmail.com>
References: <20120905213941.03c85968@arrowsmith>
	<C71A36A8-08D2-4D3D-AF2B-EF89FEECE1A6@alum.mit.edu>
	<20120906073615.693d14e0@arrowsmith>
	<46AB14E3-73F4-41FA-8086-F1D663AF4549@alum.mit.edu>
	<20120907074910.2df46817@arrowsmith>
	<20120908030311.GM17289@tassilo.jf.intel.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6FE4@saturn3.aculab.com>
	<1347269124.1234.1326.camel@edumazet-glaptop>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6FE5@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andi Kleen <ak@linux.intel.com>,
	George Bakos <gbakos@alpinista.org>,
	tcpdump-workers@lists.tcpdump.org,
	Jay Schulist <jschlst@samba.org>, netdev@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36423 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757366Ab2IJLto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 07:49:44 -0400
Received: from [78.46.5.204] (helo=sslproxy02.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TB2Up-0004RE-Am
	for netdev@vger.kernel.org; Mon, 10 Sep 2012 13:49:43 +0200
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy02.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TB2My-0005NV-6n
	for netdev@vger.kernel.org; Mon, 10 Sep 2012 13:41:36 +0200
Received: by eekc1 with SMTP id c1so1046500eek.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 04:49:37 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FE5@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 10, 2012 at 12:41 PM, David Laight <David.Laight@aculab.com> wrote:
>> > What about the other OS - eg all the BSDs?
>> > I had a vague idea that BPF was supposed to be reasonable portable.
>>
>> Yes, does it mean BPF is frozen ?
>>
>> Or is BSD so hard to update these days ?
>
> Not really - but it some other places that need updating in order
> to make this useful for cross-platform tools (like tcpdump).
>
> The 'real fun (tm)' happens when NetBSD tries to run Linux binaries
> that include the Linux libpcap.

Correct me if I'm wrong, but if you want to run the _Linux_ version of
libpcap, then you would also need PF_PACKET's RX_RING API in NetBSD.
Otherwise, it doesn't run either. Probably then this BPF instruction
is the smaller problem for NetBSD.
