From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: linux-next: build warnings after merge of the net-next tree
Date: Tue, 22 Nov 2016 09:23:38 +0100
Message-ID: <20161122092338.1b788f05@free-electrons.com>
References: <20161122122216.575b1793@canb.auug.org.au>
        <e5c5a4d7-355e-b8a6-9526-d6acbe4e54f8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Gregory Clement <gregory.clement@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <e5c5a4d7-355e-b8a6-9526-d6acbe4e54f8@gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, 21 Nov 2016 17:28:39 -0800, Florian Fainelli wrote:
> +Thomas, Gregory,
> 
> On 11/21/2016 05:22 PM, Stephen Rothwell wrote:
> [snip]
> > 
> > Introduced by commit
> > 
> >   a0627f776a45 ("net: marvell: Allow drivers to be built with COMPILE_TEST")
> > 
> > "a few warnings" is a matter of perception.  :-(  
> 
> Thomas, based on our IRC conversation, do you already have patches for
> mvneta and mvpp2 to build without warning on 64-bit or should I prepare
> patches for these?

Yes, we already have patches for making mvneta and mvpp2 build without
warning for 64-bit (Grégory for mvneta, and myself for mvpp2). I
intended to send the mvpp2 ones together with patches adding support
for a new variant of the IP, but I guess I can send just the few ones
that make it 64-bit "buildable".

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
