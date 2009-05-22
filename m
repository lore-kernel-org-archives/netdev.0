From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] can: SJA1000: generic OF platform bus driver
Date: Thu, 21 May 2009 23:31:23 -0700 (PDT)
Message-ID: <20090521.233123.135354184.davem@davemloft.net>
References: <4A143896.7050200@grandegger.com>
	<fa686aa40905212142n4a8c3caamb2f28eef036e3922@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org,
	Linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
To: grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
In-Reply-To: <fa686aa40905212142n4a8c3caamb2f28eef036e3922-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Date: Thu, 21 May 2009 22:42:07 -0600

> On Wed, May 20, 2009 at 11:06 AM, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>=
 wrote:
>> This patch adds a generic driver for SJA1000 chips on the OpenFirmware
>> platform bus found on embedded PowerPC systems. You need a SJA1000 node
>> definition in your flattened device tree source (DTS) file similar to:
>>
>> =A0 can@3,100 {
>> =A0 =A0 =A0 =A0 =A0 compatible =3D "philips,sja1000";
>> =A0 =A0 =A0 =A0 =A0 reg =3D <3 0x100 0x80>;
>> =A0 =A0 =A0 =A0 =A0 clock-frequency =3D <8000000>;
>> =A0 =A0 =A0 =A0 =A0 cdr-reg =3D <0x48>;
>> =A0 =A0 =A0 =A0 =A0 ocr-reg =3D <0x0a>;
>> =A0 =A0 =A0 =A0 =A0 interrupts =3D <2 0>;
>> =A0 =A0 =A0 =A0 =A0 interrupt-parent =3D <&mpic>;
>> =A0 };
> =

> This new binding must be documented in Documentation/powerpc/dts-bindings

Wolfgang, please add this documentation and resubmit your patch.
Thanks!
