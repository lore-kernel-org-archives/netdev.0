From: Pekka Pietikainen <pp@netppl.fi>
Subject: Re: [PATCH] IPsec: add support for Twofish and Serpent
Date: Thu, 14 Aug 2003 21:08:57 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030814180857.GA4205@netppl.fi>
References: <20030814164819.GA18948@imladris.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: jmorris@intercode.com.au, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kyle McMartin <kyle@debian.org>
Content-Disposition: inline
In-Reply-To: <20030814164819.GA18948@imladris.debian.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Aug 14, 2003 at 12:48:19PM -0400, Kyle McMartin wrote:
> 
> This patch adds support for the use of twofish and serpent as
> ESP algorithms. The ESP index numbers given are in accordance
> with RFC2407, draft-ietf-ipsec-ciph-aes-cbc-00 (before Rijndael
> was selected), and KAME which assigns 253 to twofishcbc.

> Support for using twofish was requested on linux-kernel, and
> since I noticed serpent was missing too, included that as well.
Hi

Nothing against twofish or serpent per se, but I have this feeling that 
supporting every possible crypto algoritm known to man
is not necessarily wise (see eg. Practical Cryptography for the rationale).

There's absolutely no need to add complexity unless there are some technical
arguments for doing so, say compatibility with legacy implementations
which justifies bothering with DES/3DES/MD5 although they're inferior to 
AES and SHA1 in just about every aspect.

-- 
Pekka Pietikainen
