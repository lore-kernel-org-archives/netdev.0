From: Peter Bieringer <pb@bieringer.de>
Subject: Re: IPv4 tunneled over IPv6-IPsec?
Date: Sun, 27 Mar 2005 14:47:38 +0200
Message-ID: <13B368C239630E8F2BA18AF3@[192.168.17.4]>
References: <E1DFUeO-0001IS-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@oss.sgi.com
In-Reply-To: <E1DFUeO-0001IS-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

thank you for quick reply.

--On Sonntag, 27. M=E4rz 2005 20:05 +1000 Herbert Xu=20
<herbert@gondor.apana.org.au> wrote:

> Peter Bieringer <pb@bieringer.de> wrote:
>>
>> I retry to play tunneling IPv4 over IPv6-IPsec. Afair it is still not
>> working (support is missing in 2.6.x kernel), but for startup, I have
>> already a patch for ipsec.conf parsing (pluto already has an option to
>> do  this):
>
> The native IPsec stack doesn't support IPv4 over IPv6 or IPv6 over
> IPv4 SAs.  It won't be able to do so unless major surgery is done
> to the IPsec and IP stack.

Hmm, looks like more a long term issue :-(

So another question: what is the status of tunneling IPv4 over IPv6 witho=
ut=20
IPsec e.g. using GRE or special native tunneling? Similar issue? I digged=
 a=20
little bit around in GRE code and found some IPv6 references but no hints=
=20
whether it can be used for that also.


BTW: the reason why I'm looking for such support is the need to connect=20
some "legacy" IPv4 islands over IPv6.

Regards,
	Peter
--=20
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
