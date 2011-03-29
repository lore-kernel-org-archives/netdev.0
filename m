From: Sasikanth V <sasikanth.v19@gmail.com>
Subject: Re: [PATCH] Bridge allows the userspace to configure the
 bridge parameters with values not defined in the IEEE 802.1D std
Date: Tue, 29 Mar 2011 21:06:47 +0530
Message-ID: <AANLkTikGEWmY1_Hyqzq2PMxz_Uu0d1t9J4Sf_GtR=dgZ@mail.gmail.com>
References: <1301150997-4639-1-git-send-email-sasikanth.v19@gmail.com>
	<20110326085536.1ef03edb@nehalam>
	<AANLkTim=futKP0Opnedc10zH83r=WYEhaSUHCtf+qbw3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6357426648230157179=="
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <AANLkTim=futKP0Opnedc10zH83r=WYEhaSUHCtf+qbw3@mail.gmail.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============6357426648230157179==
Content-Type: multipart/alternative; boundary=90e6ba53aa000465de049fa0d4f7

--90e6ba53aa000465de049fa0d4f7
Content-Type: text/plain; charset=ISO-8859-1

On Sun, Mar 27, 2011 at 12:01 AM, Sasikanth V <sasikanth.v19@gmail.com>wrote:

>
>
> On Sat, Mar 26, 2011 at 9:25 PM, Stephen Hemminger <
> shemminger@linux-foundation.org> wrote:
>
>> On Sat, 26 Mar 2011 20:19:57 +0530
>> Sasikanth V <sasikanth.v19@gmail.com> wrote:
>>
>> >
>> > Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
>> > ---
>>
>> I will clean this up. There are things like introducing
>> global function names (set_forward_delay, etc) that need
>> to be fixed.
>>
>
>    Thanks for looking at the patch.  I made 5 set functions
> (set_forward_delay, set_max_age,
>    set_hello_time, set_priority and set_ageing_time) in br_sysfs_br.c
> global to use in br_ioctl.c to
>    avoid code duplication (but it looks it is not a good idea).
>
>    Now  i thought something like making those 5 functions static inline and
> moving it to br_private.h.
>    If this is fine , I will resend the patch
>
>
>
>   Since I am new to patch states and workflow. Can you guys please let me,
what  I have to do when the
  patch state is in Awaiting Stream.

  Thanks

--90e6ba53aa000465de049fa0d4f7
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br><div class=3D"gmail_quote">On Sun, Mar 27, 2011 at=
 12:01 AM, Sasikanth V <span dir=3D"ltr">&lt;<a href=3D"mailto:sasikanth.v1=
9@gmail.com">sasikanth.v19@gmail.com</a>&gt;</span> wrote:<br><blockquote c=
lass=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex; border-left: 1px s=
olid rgb(204, 204, 204); padding-left: 1ex;">
<div dir=3D"ltr"><div><div></div><div class=3D"h5">
<br><br><div class=3D"gmail_quote">On Sat, Mar 26, 2011 at 9:25 PM, Stephen=
 Hemminger <span dir=3D"ltr">&lt;<a href=3D"mailto:shemminger@linux-foundat=
ion.org" target=3D"_blank">shemminger@linux-foundation.org</a>&gt;</span> w=
rote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex; borde=
r-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
<div>On Sat, 26 Mar 2011 20:19:57 +0530<br>
Sasikanth V &lt;<a href=3D"mailto:sasikanth.v19@gmail.com" target=3D"_blank=
">sasikanth.v19@gmail.com</a>&gt; wrote:<br>
<br>
&gt;<br>
&gt; Signed-off-by: Sasikanth V &lt;<a href=3D"mailto:sasikanth.v19@gmail.c=
om" target=3D"_blank">sasikanth.v19@gmail.com</a>&gt;<br>
&gt; ---<br>
<br>
</div>I will clean this up. There are things like introducing<br>
global function names (set_forward_delay, etc) that need<br>
to be fixed.<br>
</blockquote></div><br></div></div>=A0=A0 Thanks for looking at the patch.=
=A0 I made 5 set functions (set_forward_delay, set_max_age, <br>=A0=A0 set_=
hello_time, set_priority and set_ageing_time) in br_sysfs_br.c global to us=
e in br_ioctl.c to <br>

=A0=A0 avoid code duplication (but it looks it is not a good idea). <br><br=
>=A0=A0 Now=A0 i thought something like making those 5 functions static inl=
ine and moving it to br_private.h.<br>=A0=A0 If this is fine , I will resen=
d the patch<br>

=A0 <br>=A0=A0 <br><br></div>
</blockquote></div>=A0 Since I am new to patch states and workflow. Can you=
 guys please let me, what=A0 I have to do when the <br>=A0 patch state is i=
n Awaiting Stream.<br><br>=A0 Thanks <br>=A0 <br></div>

--90e6ba53aa000465de049fa0d4f7--

--===============6357426648230157179==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/bridge
--===============6357426648230157179==--
