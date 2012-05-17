From: Andre Bella <scancool@yahoo.com>
Subject: Re: [RFC 13/13] USB: Disable hub-initiated LPM for
	comms devices.
Date: Thu, 17 May 2012 10:50:31 -0700 (PDT)
Message-ID: <1337277031.3460.YahooMailClassic@web160704.mail.bf1.yahoo.com>
References: <20120517173150.GE4967@xanatos>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0065834560=="
Cc: gigaset307x-common@lists.sourceforge.net, libertas-dev@lists.infradead.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	users@rt2x00.serialmonkey.com, linux-bluetooth@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, Alan Stern <stern@rowland.harvard.edu>,
	Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <20120517173150.GE4967@xanatos>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Mime-version: 1.0
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

--===============0065834560==
Content-Type: multipart/alternative; boundary="-672873354-1662837441-1337277031=:3460"

---672873354-1662837441-1337277031=:3460
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

I dont know, sorry,

--- On Thu, 5/17/12, Sarah Sharp <sarah.a.sharp@linux.intel.com> wrote:

From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [RFC 13/13] USB: Disable hub-initiated LPM for comms devices.
To: "Tilman Schmidt" <tilman@imap.cc>
Cc: gigaset307x-common@lists.sourceforge.net, libertas-dev@lists.infradead.=
org, "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>, linux-usb@vger.kern=
el.org, linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com, linu=
x-bluetooth@vger.kernel.org, ath9k-devel@lists.ath9k.org, "Alan Stern" <ste=
rn@rowland.harvard.edu>, "Hansjoerg Lipp" <hjlipp@web.de>, netdev@vger.kern=
el.org
Date: Thursday, May 17, 2012, 1:31 PM

On Thu, May 17, 2012 at 07:07:32PM +0200, Tilman Schmidt wrote:
> Am 16.05.2012 23:55, schrieb Sarah Sharp:
> > Set the disable_hub_initiated_lpm flag for for all USB communications
> > drivers.=A0 I know there aren't currently any USB 3.0 devices that
> > implement these class specifications, but we should be ready if they do=
.
>=20
> I follow the argument for class drivers. But this patch also
> modifies drivers for specific existing USB 2.0 only devices
> which are unlikely to ever grow USB 3.0 support, such as the
> Gigaset ISDN driver:
>=20
> >=A0 drivers/isdn/gigaset/bas-gigaset.c=A0 =A0 =A0 =A0 =A0 =A0 |=A0 =A0 1=
 +
> >=A0 drivers/isdn/gigaset/usb-gigaset.c=A0 =A0 =A0 =A0 =A0 =A0 |=A0 =A0 1=
 +

Is there a particular reason why you think that driver is unlikely to
ever get USB 3.0 support?=A0 I pretty much grabbed any USB driver that
looked like a communications driver without looking too closely at the
code.

> What is the interest of setting the disable_hub_initiated_lpm
> flag for these?

It's partially to lay the foundation for anyone who wants to make a USB
3.0 communications driver in the future.=A0 They're likely to start from
some USB 2.0 class driver, and copy a lot of code.=A0 If they notice that
flag is set in all the USB communications class drivers, they're likely
to set it as well.

I'm not quite sure where the best place to provide documentation on the
flag is.=A0 I've added the kernel doc comments to the structure, but maybe
it needs to be documented somewhere in Documentation/usb/?

Sarah Sharp

_______________________________________________
libertas-dev mailing list
libertas-dev@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/libertas-dev

---672873354-1662837441-1337277031=:3460
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<table cellspacing=3D"0" cellpadding=3D"0" border=3D"0" ><tr><td valign=3D"=
top" style=3D"font: inherit;">I dont know, sorry,<br><br>--- On <b>Thu, 5/1=
7/12, Sarah Sharp <i>&lt;sarah.a.sharp@linux.intel.com&gt;</i></b> wrote:<b=
r><blockquote style=3D"border-left: 2px solid rgb(16, 16, 255); margin-left=
: 5px; padding-left: 5px;"><br>From: Sarah Sharp &lt;sarah.a.sharp@linux.in=
tel.com&gt;<br>Subject: Re: [RFC 13/13] USB: Disable hub-initiated LPM for =
comms devices.<br>To: "Tilman Schmidt" &lt;tilman@imap.cc&gt;<br>Cc: gigase=
t307x-common@lists.sourceforge.net, libertas-dev@lists.infradead.org, "Greg=
 Kroah-Hartman" &lt;gregkh@linuxfoundation.org&gt;, linux-usb@vger.kernel.o=
rg, linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com, linux-bl=
uetooth@vger.kernel.org, ath9k-devel@lists.ath9k.org, "Alan Stern" &lt;ster=
n@rowland.harvard.edu&gt;, "Hansjoerg Lipp" &lt;hjlipp@web.de&gt;, netdev@v=
ger.kernel.org<br>Date: Thursday, May 17, 2012, 1:31 PM<br><br><div
 class=3D"plainMail">On Thu, May 17, 2012 at 07:07:32PM +0200, Tilman Schmi=
dt wrote:<br>&gt; Am 16.05.2012 23:55, schrieb Sarah Sharp:<br>&gt; &gt; Se=
t the disable_hub_initiated_lpm flag for for all USB communications<br>&gt;=
 &gt; drivers.&nbsp; I know there aren't currently any USB 3.0 devices that=
<br>&gt; &gt; implement these class specifications, but we should be ready =
if they do.<br>&gt; <br>&gt; I follow the argument for class drivers. But t=
his patch also<br>&gt; modifies drivers for specific existing USB 2.0 only =
devices<br>&gt; which are unlikely to ever grow USB 3.0 support, such as th=
e<br>&gt; Gigaset ISDN driver:<br>&gt; <br>&gt; &gt;&nbsp; drivers/isdn/gig=
aset/bas-gigaset.c&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; |&nbsp; &nbsp; =
1 +<br>&gt; &gt;&nbsp; drivers/isdn/gigaset/usb-gigaset.c&nbsp; &nbsp; &nbs=
p; &nbsp; &nbsp; &nbsp; |&nbsp; &nbsp; 1 +<br><br>Is there a particular rea=
son why you think that driver is unlikely to<br>ever get USB 3.0
 support?&nbsp; I pretty much grabbed any USB driver that<br>looked like a =
communications driver without looking too closely at the<br>code.<br><br>&g=
t; What is the interest of setting the disable_hub_initiated_lpm<br>&gt; fl=
ag for these?<br><br>It's partially to lay the foundation for anyone who wa=
nts to make a USB<br>3.0 communications driver in the future.&nbsp; They're=
 likely to start from<br>some USB 2.0 class driver, and copy a lot of code.=
&nbsp; If they notice that<br>flag is set in all the USB communications cla=
ss drivers, they're likely<br>to set it as well.<br><br>I'm not quite sure =
where the best place to provide documentation on the<br>flag is.&nbsp; I've=
 added the kernel doc comments to the structure, but maybe<br>it needs to b=
e documented somewhere in Documentation/usb/?<br><br>Sarah Sharp<br><br>___=
____________________________________________<br>libertas-dev mailing list<b=
r><a ymailto=3D"mailto:libertas-dev@lists.infradead.org"
 href=3D"/mc/compose?to=3Dlibertas-dev@lists.infradead.org">libertas-dev@li=
sts.infradead.org</a><br><a href=3D"http://lists.infradead.org/mailman/list=
info/libertas-dev" target=3D"_blank">http://lists.infradead.org/mailman/lis=
tinfo/libertas-dev</a><br></div></blockquote></td></tr></table>
---672873354-1662837441-1337277031=:3460--

--===============0065834560==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
ath9k-devel mailing list
ath9k-devel@lists.ath9k.org
https://lists.ath9k.org/mailman/listinfo/ath9k-devel

--===============0065834560==--
