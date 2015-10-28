From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 3/9] powerpc32: checksum_wrappers_64 becomes
 checksum_wrappers
Date: Wed, 28 Oct 2015 22:11:49 +1100
Message-ID: <20151028221149.2febe8a6@kryten>
References: <cover.1442876807.git.christophe.leroy@c-s.fr>
	<91ebacbbd631ec02ad00e0a824b6cad0dac532a0.1442876807.git.christophe.leroy@c-s.fr>
	<1445570793.701.147.camel@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christophe Leroy <christophe.leroy@c-s.fr>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<netdev@vger.kernel.org>
To: Scott Wood <scottwood@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445570793.701.147.camel@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Scott,

> I wonder why it was 64-bit specific in the first place.

I think it was part of a series where I added my 64bit assembly checksum
routines, and I didn't step back and think that the wrapper code would
be useful on 32 bit.

Anton
