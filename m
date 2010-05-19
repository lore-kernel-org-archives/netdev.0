From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [RFC] netem: correlated loss generation (v3)
Date: Thu, 20 May 2010 01:04:33 +0200
Message-ID: <20100519230433.GE5146@nuttenaction>
References: <4BD84428.30904@uniroma2.it>
 <20100517205621.036a06e0@nehalam>
 <20100519214239.GD5146@nuttenaction>
 <4BF46B90.1000806@uniroma2.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Fabio Ludovici <fabio.ludovici@yahoo.it>,
	netdev@vger.kernel.org, netem@lists.linuxfoundation.org
To: Stefano Salsano <stefano.salsano@uniroma2.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:33214 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751041Ab0ESXEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 19:04:35 -0400
Content-Disposition: inline
In-Reply-To: <4BF46B90.1000806@uniroma2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stefano Salsano | 2010-05-20 00:52:00 [+0200]:

>So my opinion is that the need to emulate "correlated" loss patterns
>is not academic, but it is a real need from industry... of course we
>can debate if it is a "niche" requirement or not

netem is not in the processing hot path, so there is no issue to add an
additional component. If there are some[TM] users and it is usable, I am
fine with this patch!

>tc qdisc change dev wlan0 root netem loss 2 10
>
>because this produces broken results...

How to model this specific network characteristic (2% loss, correlation 10%)
with your modifications? Can you give us an example?

Cheers, Hagen

-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22
