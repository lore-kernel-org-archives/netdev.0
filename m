From: =?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH Linux-2.6.7-bk19] prism54 freq to
	channel incorrect for 5GHz
Date: Wed, 07 Jul 2004 09:49:11 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <hvhdskl0js.fsf@rasputin.ws.nextra.no>
References: <200407070831.47896.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: margitsw@t-online.de (Margit Schubert-While)
In-Reply-To: <200407070831.47896.margitsw@t-online.de> (Margit
	Schubert-While's message of "Wed, 7 Jul 2004 08:31:47 +0200")
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

margitsw@t-online.de (Margit Schubert-While) writes:

> Note that AFAIK, the 5GHz WLAN channels start at 34 (5.17 GHz)
> (but I am not sure)

802.11a defines all channels 0..200, i.e. all center frequencies from
5 to 6 GHz.  But I don't know any country which allows usage of the 5 GHz=20
band below 5150 MHz, and the lowest channel should be at least 20 MHz
from the band edge, so 34 is probably the lowest channel that legally
can be used anywhere (and I believe 36 is the lowest allowed in the US?)

> and I don't know the top limit (except that
> it is <=3D 6GHz). Maybe somebody can shed light on this.

The highest available frequency (in Europe at least) is 5875 MHz.
Which would make 171 the highest available channel (given a 20 MHz
minimum distance from the center frequency to the band edge).

> Apparently Japan is doing something in the 10GHz band -
> will have to look for details.

That would require a new PHY standard.


Bj=F8rn
