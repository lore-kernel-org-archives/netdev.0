From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 15:48:43 +0200
Message-ID: <200504221548.44560.wolfgang.walter@studentenwerk.mhn.de>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <200504221522.49403.wolfgang.walter@studentenwerk.mhn.de> <20050422132758.GA22772@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050422132758.GA22772@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Am Freitag, 22. April 2005 15:27 schrieb Herbert Xu:
> On Fri, Apr 22, 2005 at 03:22:49PM +0200, Wolfgang Walter wrote:
> > I'm not sure how packets of tunnels ending at a host are treated exac=
tly.
> > Probably the tunnel-packet itself is checked against XFRM_POLICY_IN
> > because its destination is the host itself. Then it gets decrypted if=
 an
> > entry appropriate in the sad in (dst,spi) exists. The inner packet ge=
ts
> > extracted and decrypted and is then rerouted.
>
> Actually it only gets checked once, after all IPsec decapsulation has b=
een
> completed.  So forwarded packets only ever get checked against the FWD
> direction.
>

So linux implements things like i.e. ipcomp in esp-tunnel in ah-tunnel as=
=20
bundle instead of feeding it for every transformation into the packet rec=
eive=20
code again? I assume that incoming packets which are subject to several=20
ipsec-transformations are exactly seen twice in netfilter PREROUTING: fir=
st=20
before decapsulation and then after complete decapsulation?

Greetings,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leopoldstra=DFe 15
80802 M=FCnchen
