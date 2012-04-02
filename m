From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC] net: bpf_jit: Two pass JIT and other changes
Date: Mon, 2 Apr 2012 10:28:07 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6ECF@saturn3.aculab.com>
References: <5185e05a69d88b5f12b5656358745b1a.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Indan Zupancic" <indan@nul.nu>,
	"Eric Dumazet" <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <5185e05a69d88b5f12b5656358745b1a.squirrel@webmail.greenhost.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> 1) Sadly, gcc isn't always smart enough to inline emit_code().
>    So turn it into a macro to force gcc to inline it. This saves
>    about 500 bytes. Tested with gcc 4.6.0. An alternative to the
>    macro would be to create inline emit_code1(), emit_code2() etc.

Does giving it the __attribute__((always_inline)) help?
I had to mark a load of small static functions that way
after a minor change (possibly to the overall size)
stopped gcc inlining everything.

I have also noticed in the past that gcc tends to generate
better code for #define than when inlining functions.

	David
