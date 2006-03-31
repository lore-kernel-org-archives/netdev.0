From: "JaniD++" <djani22@dynamicweb.hu>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 14:02:04 +0200
Message-ID: <00f701c654ba$f3c6cc60$1600a8c0@dcccs>
References: <200603311057.07213.netdev@axxeo.de> <E1FPFkT-0002om-00@gondolin.me.apana.org.au> <20060331.013540.95485284.davem@davemloft.net> <20060331094240.GA11040@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: <netdev@axxeo.de>, <jesse.brandeburg@intel.com>,
	<nipsy@bitgnome.net>, <jrlundgren@gmail.com>, <cat@zip.com.au>,
	<djani22@dynamicweb.hu>, <yoseph.basri@gmail.com>,
	<bb@kernelpanic.ru>, <mykleb@no.ibm.com>, <olel@ans.pl>,
	<michal@feix.cz>, <chris@scorpion.nl>, <netdev@vger.kernel.org>,
	"Jesse Brandeburg" <jesse.brandeburg@gmail.com>,
	<E1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org


----- Original Message -----=20
From: "Herbert Xu" <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Cc: <netdev@axxeo.de>; <jesse.brandeburg@intel.com>; <nipsy@bitgnome.net>=
;
<jrlundgren@gmail.com>; <cat@zip.com.au>; <djani22@dynamicweb.hu>;
<yoseph.basri@gmail.com>; <bb@kernelpanic.ru>; <mykleb@no.ibm.com>;
<olel@ans.pl>; <michal@feix.cz>; <chris@scorpion.nl>;
<netdev@vger.kernel.org>; <jesse.brandeburg@gmail.com>;
<E1000-devel@lists.sourceforge.net>
Sent: Friday, March 31, 2006 11:42 AM
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed..=
.


> On Fri, Mar 31, 2006 at 01:35:40AM -0800, David S. Miller wrote:
> >
> > He does not have TSO enabled, e1000 disables TSO when on a link speed
> > slower than gigabit.
>
> Indeed.  But I think that only happens on PCI Express and I don't think
> Ingo is using PCI Express.

No, my card is "64-bit PCI-X Rev. 1.0 master interface".  - from the
datasheet
Number : "82546GB"
This is not PCI Express issue!

Cheers,

>
> Cheers,
> --=20
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>  _____________ NOD32 1.584 (20031220) Inform=E1ci=F3 _____________
>
> Az =FCzenetet a NOD32 Antivirus System megvizsg=E1lta.
> http://www.nod32.hu
>
>



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
