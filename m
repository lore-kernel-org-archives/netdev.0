From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPsec: add support for Twofish and Serpent
Date: Thu, 14 Aug 2003 23:25:11 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308142324310.29579-100000@netcore.fi>
References: <20030814180857.GA4205@netppl.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kyle McMartin <kyle@debian.org>, <jmorris@intercode.com.au>,
   <netdev@oss.sgi.com>, <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@netppl.fi>
In-Reply-To: <20030814180857.GA4205@netppl.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 14 Aug 2003, Pekka Pietikainen wrote:
> On Thu, Aug 14, 2003 at 12:48:19PM -0400, Kyle McMartin wrote:
> > 
> > This patch adds support for the use of twofish and serpent as
> > ESP algorithms. The ESP index numbers given are in accordance
> > with RFC2407, draft-ietf-ipsec-ciph-aes-cbc-00 (before Rijndael
> > was selected), and KAME which assigns 253 to twofishcbc.
> 
> > Support for using twofish was requested on linux-kernel, and
> > since I noticed serpent was missing too, included that as well.
> Hi
> 
> Nothing against twofish or serpent per se, but I have this feeling that 
> supporting every possible crypto algoritm known to man
> is not necessarily wise (see eg. Practical Cryptography for the rationale).
> 
> There's absolutely no need to add complexity unless there are some technical
> arguments for doing so, say compatibility with legacy implementations
> which justifies bothering with DES/3DES/MD5 although they're inferior to 
> AES and SHA1 in just about every aspect.

Very much agree.

Also, I could be missing something, but I think it takes much more to add 
an encryption algorithm than what the patch does?!?!

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
