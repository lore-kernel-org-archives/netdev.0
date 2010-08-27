From: Jacob Keller <jacob.keller@gmail.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 27 Aug 2010 09:17:10 -0700
Message-ID: <AANLkTimG+cMnGL=K9Cf1Xjhnh3HKyH3k-scXRHLQdh7Y@mail.gmail.com>
References: <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	<AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
	<20100817085324.GB3330@riccoc20.at.omicron.at>
	<1282090963.1734.97.camel@localhost>
	<20100818071942.GA4096@riccoc20.at.omicron.at>
	<1282176776.2865.100.camel@localhost.localdomain>
	<20100819055518.GA4084@riccoc20.at.omicron.at>
	<1282594125.3111.344.camel@localhost.localdomain>
	<20100827123849.GC11657@riccoc20.at.omicron.at>
	<20100827143844.646eccf6@lxorguk.ukuu.org.uk>
	<20100827143437.GB3293@riccoc20.at.omicron.at>
	<20100827160624.433b3374@lxorguk.ukuu.org.uk>
	<4C77D804.9060500@gmx.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3431470555409960244=="
Cc: Rodolfo Giometti <giometti@linux.it>, Arnd Bergmann <arnd@arndb.de>,
	john stultz <johnstul@us.ibm.com>,
	Richard Cochran <richardcochran@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Patrick Loschmidt <Patrick.Loschmidt@gmx.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <4C77D804.9060500@gmx.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

--===============3431470555409960244==
Content-Type: multipart/alternative; boundary=001517478b50a36814048ed07392

--001517478b50a36814048ed07392
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Aug 27, 2010 at 8:06 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote

> > > system time bimble track a source makes sense just as with NTP but
> making
> > > it a new clock seems the wrong model extending a non-too-bright API
> when
> > > you can just put the time sources in a file tree.
> >
> > Don't get your meaning here, what did you mean by "file tree?"
>
> Something like
>
>        /sys/class/timesource/<name>/...
>
> at which point we don't have to enumerate them all, add special system
> calls and then fret about the fact you can't access them from things like
> shell scripts.
>

I agree that this interface is the best way to be future proof. This appears
to allow for multiple "clocks" or nodes, and doesn't get messed up when we
add more than one NIC with separate clocks to a machine.

--001517478b50a36814048ed07392
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 27, 2010 at 8:06 AM, Alan Cox <span dir=3D"ltr">&lt;<a href=3D"=
mailto:alan@lxorguk.ukuu.org.uk">alan@lxorguk.ukuu.org.uk</a>&gt;</span> wr=
ote<br>
<blockquote class=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex; borde=
r-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;"><div class=3D"im"=
>
&gt; &gt; system time bimble track a source makes sense just as with NTP bu=
t making<br>
&gt; &gt; it a new clock seems the wrong model extending a non-too-bright A=
PI when<br>
&gt; &gt; you can just put the time sources in a file tree.<br>
&gt;<br>
&gt; Don&#39;t get your meaning here, what did you mean by &quot;file tree?=
&quot;<br>
<br>
</div>Something like<br>
<br>
 =A0 =A0 =A0 =A0/sys/class/timesource/&lt;name&gt;/...<br>
<br>
at which point we don&#39;t have to enumerate them all, add special system<=
br>
calls and then fret about the fact you can&#39;t access them from things li=
ke<br>
shell scripts.<br>
</blockquote><br>
I agree that this interface is the best way to be future proof. This=20
appears to allow for multiple &quot;clocks&quot; or nodes, and doesn&#39;t =
get messed=20
up when we add more than one NIC with separate clocks to a machine.<br>

--001517478b50a36814048ed07392--

--===============3431470555409960244==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============3431470555409960244==--
