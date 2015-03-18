From: Shannon Nelson <shannon.nelson@intel.com>
Subject: Re: PCI passthrough of 40G ethernet interface
	(Openstack/KVM)
Date: Wed, 18 Mar 2015 15:01:59 -0700
Message-ID: <CAP-MU4PSMMOv-sjfDtKOSaHa9-dy3cMovsHV7V_cV1k6N7yvFg@mail.gmail.com>
References: <CA+AkT2g=vFxKAUrHzWDxPzfq_SNvOUJvzHe5YsX+p+p6Ad8hog@mail.gmail.com>
	<jpg8uf2ghln.fsf@redhat.com>
	<CA+AkT2hZ5e=YRkSqQnpQm9CgfC_fqs-m_05FTRZQLt9ynj9A4w@mail.gmail.com>
	<jpgtwxpvk5x.fsf@redhat.com>
	<CA+AkT2j9UUTVmEsW1B4D_cvfCTjp-+62qhvnYxcrthy=QmQcaw@mail.gmail.com>
	<CA+AkT2gXouCdMWzRJBY0jYi6O61OjDnNf7XGnfLzhYkJCe00mg@mail.gmail.com>
	<jpg1tko7qwb.fsf@redhat.com>
	<CA+AkT2i2z+DGV0aezUQaOLKrVupprniuxC19xGOuNnd6gC1ZGg@mail.gmail.com>
	<jpglhiw4tal.fsf@redhat.com> <jpgk2yewcpt.fsf@redhat.com>
	<CA+AkT2g-Xt+hcpoh2ETx70v0mzV6m=-5zpxJrhs2C8WF--kmWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=20cf302447bb7acfa00511973bca
Cc: kvm-devel <kvm@vger.kernel.org>, netdev@vger.kernel.org,
	Alex Williamson <alex.williamson@redhat.com>,
	QEMU Developers <qemu-devel@nongnu.org>, Bandan Das <bsd@redhat.com>,
	Stefan Assmann <sassmann@redhat.com>
To: jacob jacob <opstkusr@gmail.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <CA+AkT2g-Xt+hcpoh2ETx70v0mzV6m=-5zpxJrhs2C8WF--kmWw@mail.gmail.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

--20cf302447bb7acfa00511973bca
Content-Type: text/plain; charset=UTF-8

On Wed, Mar 18, 2015 at 8:40 AM, jacob jacob <opstkusr@gmail.com> wrote:
>
> On Wed, Mar 18, 2015 at 11:24 AM, Bandan Das <bsd@redhat.com> wrote:
> >
> > Actually, Stefan suggests that support for this card is still sketchy
> > and your best bet is to try out net-next
> > http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git
> >
> > Also, could you please post more information about your hardware setup
> > (chipset/processor/firmware version on the card etc) ?
>
> Host CPU : Model name:            Intel(R) Xeon(R) CPU E5-2630 v2 @
2.60GHz
>
> Manufacturer Part Number:  XL710QDA1BLK
> Ethernet controller: Intel Corporation Ethernet Controller XL710 for
> 40GbE QSFP+ (rev 01)
>  #ethtool -i enp9s0
> driver: i40e
> version: 1.2.6-k
> firmware-version: f4.22 a1.1 n04.24 e800013fd
> bus-info: 0000:09:00.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: yes
> supports-register-dump: yes
> supports-priv-flags: no
>

Jacob,

It looks like you're using a NIC with the e800013fd firmware from last
summer, and from a separate message that you saw these issues with both the
1.2.2-k and the 1.2.37 version drivers.  I suggest the next step would be
to update the NIC firmware as there are some performance and stability
updates available that deal with similar issues.  Please see the Intel
Networking support webpage at
https://downloadcenter.intel.com/download/24769 and look for
the NVMUpdatePackage.zip.  This should take care of several of the things
Stefan might describe as "sketchy" :-).

sln

--20cf302447bb7acfa00511973bca
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br>On Wed, Mar 18, 2015 at 8:40 AM, jacob jacob &lt;<a hr=
ef=3D"mailto:opstkusr@gmail.com">opstkusr@gmail.com</a>&gt; wrote:<br>&gt;<=
br>&gt; On Wed, Mar 18, 2015 at 11:24 AM, Bandan Das &lt;<a href=3D"mailto:=
bsd@redhat.com">bsd@redhat.com</a>&gt; wrote:<br>&gt; &gt; <br>&gt; &gt; Ac=
tually, Stefan suggests that support for this card is still sketchy<br>&gt;=
 &gt; and your best bet is to try out net-next<br>&gt; &gt; <a href=3D"http=
://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git">http://git.kern=
el.org/cgit/linux/kernel/git/davem/net-next.git</a><br><div>&gt; &gt;<br>&g=
t; &gt; Also, could you please post more information about your hardware se=
tup<br>&gt; &gt; (chipset/processor/firmware version on the card etc) ?<br>=
&gt;<br>&gt; Host CPU : Model name: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0Intel(R) Xeon(R) CPU E5-2630 v2 @ 2.60GHz<br>&gt;<br>&gt; Manufacturer P=
art Number: =C2=A0XL710QDA1BLK<br>&gt; Ethernet controller: Intel Corporati=
on Ethernet Controller XL710 for<br>&gt; 40GbE QSFP+ (rev 01)<br>&gt; =C2=
=A0#ethtool -i enp9s0<br>&gt; driver: i40e<br>&gt; version: 1.2.6-k<br>&gt;=
 firmware-version: f4.22 a1.1 n04.24 e800013fd<br>&gt; bus-info: 0000:09:00=
.0<br>&gt; supports-statistics: yes<br>&gt; supports-test: yes<br>&gt; supp=
orts-eeprom-access: yes<br>&gt; supports-register-dump: yes<br>&gt; support=
s-priv-flags: no<br>&gt;<br><br>Jacob,</div><div><br></div><div>It looks li=
ke you&#39;re using a NIC with the e800013fd firmware from last summer, and=
 from a separate message that you saw these issues with both the 1.2.2-k an=
d the 1.2.37 version drivers.=C2=A0 I suggest the next step would be to upd=
ate the NIC firmware as there are some performance and stability updates av=
ailable that deal with similar issues.=C2=A0 Please see the Intel Networkin=
g support webpage at <a href=3D"https://downloadcenter.intel.com/download/2=
4769">https://downloadcenter.intel.com/download/24769</a> and look for the=
=C2=A0NVMUpdatePackage.zip.=C2=A0 This should take care of several of the t=
hings Stefan might describe as &quot;sketchy&quot; :-).<br><br>sln<br><br><=
/div></div>

--20cf302447bb7acfa00511973bca--
