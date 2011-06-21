From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Tue, 21 Jun 2011 16:33:57 -0600
Message-ID: <BANLkTikBUo3jO=R0amkdxU1V3QMJoOUkEw@mail.gmail.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-2-git-send-email-shawn.guo@linaro.org> <20110618161934.GH8195@ponder.secretlab.ca>
 <20110619073000.GA23171@S2100-06.ap.freescale.net> <20110621135558.GB9228@S2101-09.ap.freescale.net>
 <BANLkTim4vunTm1176MRw3pqRZnunu4=9jg@mail.gmail.com> <4E00F290.2010303@firmworks.com>
 <BANLkTik9LXTJ--fRwUBscokWraPwOZnpHA@mail.gmail.com> <4E011678.4030208@firmworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: patches@linaro.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	Shawn Guo <shawn.guo@freescale.com>,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org
To: Mitch Bradley <wmb@firmworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E011678.4030208@firmworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2011 at 4:08 PM, Mitch Bradley <wmb@firmworks.com> wrot=
e:
> On 6/21/2011 9:38 AM, Grant Likely wrote:
>>
>> On Tue, Jun 21, 2011 at 1:35 PM, Mitch Bradley<wmb@firmworks.com> =A0=
wrote:
>>>
>>> What is the problem with
>>>
>>> aliases{
>>> =A0 serial0 =3D "/uart@7000c000";
>>> }
>>>
>>> Properties in the alias node are supposed to have string values.
>>
>> ?
>>
>> Not sure I follow. =A0Indeed, properties in the aliases node are str=
ing
>> values.
>>
>> Are you referring to how I was proposing some dtc syntax for
>> generating the alias strings?
>
>
> The point is that if you refer to the node explicitly by its string n=
ame,
> the need for a label disappears and the problem of overriding a defau=
lt
> alias disappears (assuming that a later redefinition of a property ta=
kes
> precedence over an earlier one, as is the OFW convention).

Ah, we're having an impedance mismatch.  I'm thinking specifically
about the device tree compiler and some syntactic sugar for using the
label definition to generate /also/ create alias properties. The
hairiness is related to that and the way that dtc is implemented, not
with the final aliases themselves.

g.
