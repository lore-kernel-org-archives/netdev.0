From: "JuanJo Ciarlante" <jjo-ipsec@mendoza.gov.ar>
Subject: Re: [CryptoAPI-devel] Re: [Design] [PATCH] USAGI IPsec
Date: Mon, 28 Oct 2002 10:55:25 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021028105525.C18414@mendoza.gov.ar>
References: <m3k7kpjt7c.wl@karaba.org> <3DB41338.3070502@storm.ca> <1035168066.4817.1.camel@rth.ninka.net> <1035185654.21824.11.camel@janus.txd.hvrlab.org> <3DB4DBC8.8647E32E@pp.inet.fi> <20021024105026.C1170@certainkey.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jari Ruusu <jari.ruusu@pp.inet.fi>,
   Herbert Valerio Riedel <hvr@hvrlab.org>,
   "David S. Miller" <davem@rth.ninka.net>, Sandy Harris <sandy@storm.ca>,
   Mitsuru KANDA <mk@linux-ipv6.org>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, cryptoapi-devel@kerneli.org, design@lists.freeswan.org,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean-Luc Cooke <jlcooke@certainkey.com>
Content-Disposition: inline
In-Reply-To: <20021024105026.C1170@certainkey.com>; from jlcooke@certainkey.com on Thu, Oct 24, 2002 at 10:50:26AM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 24, 2002 at 10:50:26AM -0400, Jean-Luc Cooke wrote:
> On Tue, Oct 22, 2002 at 08:02:00AM +0300, Jari Ruusu wrote:
> > kerneli.org/cryptoapi _is_ useless joke for many needs. Fortunately other
> > people are able to see the limitations/sillyness of kerneli.org/cryptoapi:
> > 
> > 1)  You are trying to replace link/insmod time overhead with runtime
> >     overhead + unnecessary bloat.
> > 2)  No direct link access to low level cipher functions or higher level
> >     functions.
> > 3)  No clean way to replace cipher code with processor type optimized
> >     assembler implementations.
> 
> Jari has a few points here.  But the "killer" functionalities are all there
> IMHO.  Low-level assembler implementations are over-rated, again IMHO.  The
> performance difference between C and ASM is at most 50%.  1ms vs 1.5 ms.
> Even if you've got a large payload on the rare occation (>5MB) block ciphers
> are quite fast for 95% of applications

According to my tests, AES ASM has given me _2x_ speed boost over C; this
fact has re-written freeswan CPU/bandwidth empirical formula to peak at
       CPU [MHz] ~= BW [Mbit/s] * 10      (instead of 25)

This boost has allowed my old Cyrix-6x86 120MHz to be my 802.11b gateway  =)


--Juanjo       freeswan algo: AES (+others), SHA2, MODP2048-4096 
               selectable algorithms support for Phase1 and 2.
	       http://www.irrigacion.gov.ar/juanjo/ipsec/

#  Juan Jose Ciarlante (JuanJo PGP) jjo ;at; mendoza.gov.ar              #
#  Key fingerprint = 76 60 A5 76 FD D2 53 E3  50 C7 90 20 22 8C F1 2D    #
