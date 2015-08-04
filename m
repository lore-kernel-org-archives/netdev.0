From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: printk from softirq on xen: hard lockup
Date: Tue, 4 Aug 2015 19:45:51 +0200
Message-ID: <CAHmME9pPMaiBhTB30MGZ20kq7pdzdxsBe5uYip3Cw1bE0FtFGA@mail.gmail.com>
References: <CAHmME9rUdafnjz0ej-z_cgznMrj27SJgy6v8GJXM0qGfUpWaMQ@mail.gmail.com>
	<55C0F291.7060806@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3198444765135302489=="
Cc: netdev@vger.kernel.org, Paul McKenney <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xen.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <55C0F291.7060806@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

--===============3198444765135302489==
Content-Type: multipart/alternative; boundary=001a113492b883c175051c7fdb50

--001a113492b883c175051c7fdb50
Content-Type: text/plain; charset=UTF-8

PV guest domU. PV host dom0.
On Aug 4, 2015 7:14 PM, "David Vrabel" <david.vrabel@citrix.com> wrote:

> On 04/08/15 17:41, Jason A. Donenfeld wrote:
> > Hi folks,
> >
> > Paul McKenney and I had an offline discussion about some rcu questions
> > that eventually lead into me investigating a strange full lock-up I'm
> > experiencing as a consequence of a printk in softirq inside of an
> > rcu_read_lock, when using Xen PV. Relevant excerpts of the
>                                 ^^  PV guest?
>
> > (gdb) target remote localhost:9999
> > Remote debugging using localhost:9999
> > __xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56
> > 56              while (native_apic_mem_read(APIC_ICR) & APIC_ICR_BUSY)
>                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  => HVM guest
>
> Which is it?
>
> A HVM guest's serial console may be particularly slow (since it's
> emulated by qemu).  Try using the PV console?
>
> David
>

--001a113492b883c175051c7fdb50
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">PV guest domU. PV host dom0.</p>
<div class=3D"gmail_quote">On Aug 4, 2015 7:14 PM, &quot;David Vrabel&quot;=
 &lt;<a href=3D"mailto:david.vrabel@citrix.com">david.vrabel@citrix.com</a>=
&gt; wrote:<br type=3D"attribution"><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On 04/08=
/15 17:41, Jason A. Donenfeld wrote:<br>
&gt; Hi folks,<br>
&gt;<br>
&gt; Paul McKenney and I had an offline discussion about some rcu questions=
<br>
&gt; that eventually lead into me investigating a strange full lock-up I&#3=
9;m<br>
&gt; experiencing as a consequence of a printk in softirq inside of an<br>
&gt; rcu_read_lock, when using Xen PV. Relevant excerpts of the<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ^^=C2=A0 PV guest?<br>
<br>
&gt; (gdb) target remote localhost:9999<br>
&gt; Remote debugging using localhost:9999<br>
&gt; __xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56<br>
&gt; 56=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (native_apic_=
mem_read(APIC_ICR) &amp; APIC_ICR_BUSY)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^=C2=A0 =3D&gt; HVM guest<br>
<br>
Which is it?<br>
<br>
A HVM guest&#39;s serial console may be particularly slow (since it&#39;s<b=
r>
emulated by qemu).=C2=A0 Try using the PV console?<br>
<br>
David<br>
</blockquote></div>

--001a113492b883c175051c7fdb50--


--===============3198444765135302489==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============3198444765135302489==--
