From: Kyle McMartin <kyle@debian.org>
Subject: Re: [PATCH] IPsec: add support for Twofish and Serpent
Date: Fri, 15 Aug 2003 13:38:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815173831.GB3119@imladris.debian.net>
References: <20030814164819.GA18948@imladris.debian.net> <20030814180857.GA4205@netppl.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@netppl.fi>
Content-Disposition: inline
In-Reply-To: <20030814180857.GA4205@netppl.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Aug 14, 2003 at 09:08:57PM +0300, Pekka Pietikainen wrote:
> There's absolutely no need to add complexity unless there are some technical
> arguments for doing so, say compatibility with legacy implementations
> which justifies bothering with DES/3DES/MD5 although they're inferior to 
> AES and SHA1 in just about every aspect.
> 
There are simple technical arguments for doing so, SERPENT and Twofish
are both either as secure, or more secure than rijndael, as it stood with
the amount of cryptanalysis the three received as part of the AES
selection process. (Serpent, as it stood, was more secure, since it had
more rounds, and more proven sboxes).

Adding more *secure* algorithms does no harm.

Regards,
-- 
Kyle McMartin <kyle@debian.org>
1024D/191FCD8A - 331A 9468 C04D 3A76 5C56  BA68 7EB7 92DF 191F CD8A
2048R/F515317D -   68 A9 0D 28 1B DF 8D 42  0F CC AF 98 A8 D5 A4 04
