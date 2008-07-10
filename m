From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 10 Jul 2008 19:20:49 -0300
Message-ID: <1jeik5-68f.ln1@tux.abusar.org.br>
References: <200807101146.26034.thomas.jarosch@intra2net.com>
	<200807101251.30712.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:38889 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992AbYGJWVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 18:21:17 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1KH4Vk-0004Du-3j
	for netdev@vger.kernel.org; Thu, 10 Jul 2008 22:21:12 +0000
Received: from c934d6e6.virtua.com.br ([201.52.214.230])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 22:21:12 +0000
Received: from fragabr by c934d6e6.virtua.com.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 22:21:12 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Jul 2008 12:51:30 +0200
Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:

> We found a workaround by putting a linux-based AVM fritz!box router between 
> kernel 2.6.25.10 and the mailserver, now the TCP connection works again,
> though it gets NATed. Still can't make any sense out of this.

	I have the same problem with connections stalled and the only
"workaround" I found is to trigger a nmap -sS to the server with the
stalled connection. I don't know why, but this helps it come back alive
again...

	But it surely is a Linux network bug introduced in 2.6.25
kernel, I'm sure (with 2.6.24 and below it doesn't happen, or maybe
we're talking about different symptoms of the same bug or 2 different
similar bugs... who knows?).

	I use the tg3 kernel module for the NIC... the same
configuration of the kernel doesn't trigger the bug with other types of
nics... so could we suspect of tg3 kernel module?

	What's your NIC?

-- 
Linux 2.6.25: Funky Weasel is Jiggy wit it
http://u-br.net
Marilyn Manson - "Wrapped in Plastic" (Portrait of an American Family -
1994)


