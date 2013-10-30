From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/5] lib: crc32: clean up spacing in test cases
Date: Wed, 30 Oct 2013 14:10:05 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73C8@saturn3.aculab.com>
References: <1383130252-1515-1-git-send-email-dborkman@redhat.com> <1383130252-1515-2-git-send-email-dborkman@redhat.com> <1383141418.12439.76.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>,
	"Daniel Borkmann" <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1383141418.12439.76.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +	{0x674bf11d, 0x00000038, 0x00000542, 0x0af6d466, 0xd8b6e4c1, 0xf6e93d6c},
>
> these could be
> 
> +	{0x674bf11d, 0x38, 0x542, 0x0af6d466, 0xd8b6e4c1, 0xf6e93d6c},

Or even:
#define X(a, b, c, d, e, f) {0x##a, 0x##b, 0x##c, 0x##d, 0x##e. 0x##f}
	X(674bf11d, 38, 542, 0af6d466, d8b6e4c1, f6e93d6c),
...
#undef X

	David
