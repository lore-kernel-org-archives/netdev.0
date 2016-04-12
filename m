From: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFT 2/2] macb: kill PHY reset code
Date: Tue, 12 Apr 2016 11:23:29 +0200
Message-ID: <570CBE91.7020406@atmel.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <2811962.eGX2i5RJbZ@wasted.cogentembedded.com>
 <20160411022802.GB4307@lunn.ch> <570BE1C5.70502@cogentembedded.com>
 <20160411181904.GB29709@lunn.ch> <570BEF46.7060105@cogentembedded.com>
 <20160411185115.GA30623@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160411185115.GA30623-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 11/04/2016 20:51, Andrew Lunn a =E9crit :
> On Mon, Apr 11, 2016 at 09:39:02PM +0300, Sergei Shtylyov wrote:
>> Hello.
>>
>> On 04/11/2016 09:19 PM, Andrew Lunn wrote:
>>
>>>>> The code you are deleting would of ignored the flags in the gpio
>>>>> property, i.e. active low.
>>>>
>>>>    Hm, you're right -- I forgot about that... :-/
>>>>
>>>>> The new code in the previous patch does
>>>>> however take the flags into account. Did you check if there are a=
ny
>>>>> device trees which have flags, which were never used, but are now
>>>>> going to be used and thus break...
>>>>
>>>>    Checked this now and found out arch/arm/boot/dts/ar91-vinco.dts=
=2E
>>>> Looks like it needs to be fixed indeed...
>>>>
>>> And this is where it gets tricky. You are breaking backwards
>>> compatibility by now respecting the flag. An old DT blob is not goi=
ng
>>> to work.
>>
>>    Do we care that much about the DT blobs that are just *wrong*?
>=20
> Wrong, but currently works.
>=20
>>> You potentially need to add a new property and deprecate the old on=
e.
>>
>>    I would like to avoid that...
>=20
> You will need the agreement from the at91-vinco maintainer.

If the at91-vinco has to be modified, you have my agreement that it can
be modified.

Bye,
--=20
Nicolas Ferre
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
