From: Paul Jakma <paul@clubi.ie>
Subject: Re: [patch 4/10] s390: network driver.
Date: Sun, 19 Dec 2004 23:54:49 +0000 (UTC)
Message-ID: <Pine.LNX.4.61.0412192349210.31558@sheen.jakma.org>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com>
 <1103484552.1046.155.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1103484552.1046.155.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 19 Dec 2004, jamal wrote:

> This is the strange part. Anyone still willing to provide a sample
> program that hangs?

I can provide instructions, or you can wait a wee bit - I didnt have 
any e1000 hardware to test with (e1000 being one of the drivers which 
has this behavious, AFAIK/TTBOMK) - but a computer with an e1000 
arrived Friday. So, give me a bit and I'll try come up with a test 
case. A simple UDP send should be enough.

> Still, I think we need to resolve the original problem.
> And I have a feeling we wont be seeing any program which
> reproduces it ;->

Just send a UDP packet - AIUI when link goes down the application can 
(or at least a window exists) where the application can send a packet 
down the file descriptor without error, but it will be queued rather 
than sent and the fd eventually blocks/returns EAGAIN.

That window is the problem.

I'll test tomorrow.

> cheers,
> jamal

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
You want to know why I kept getting promoted?  Because my mouth knows more
than my brain.
 	-- W.G.
