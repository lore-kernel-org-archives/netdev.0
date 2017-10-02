From: Zhi Wang <zhi.wang.linux@gmail.com>
Subject: Re: [PATCH 00/18] use ARRAY_SIZE macro
Date: Mon, 2 Oct 2017 20:05:41 +0300
Message-ID: <CAN=xO46tCDaaHRdaDmXgaJ+ub3nfEWvZLnMeih+3C4zcxoU-0Q@mail.gmail.com>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0646744013=="
Cc: alsa-devel@alsa-project.org, nouveau@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, dm-devel@redhat.com,
 brcm80211-dev-list@cypress.com, devel@driverdev.osuosl.org,
 linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
 amd-gfx@lists.freedesktop.org,
 Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, linux-acpi@vger.kernel.org,
 linux-video@atrey.karlin.mff.cuni.cz, intel-wired-lan@lists.osuosl.org,
 linux-media@vger.kernel.org, intel-gfx@lists.freedesktop.org,
 ecryptfs@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-raid@vger.kernel.org, openipmi-developer@lists.sourceforge.net,
 intel-gvt-dev@lists.freedesktop.org, devel@acpica.org,
 brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-integrity@vger.kernel.org
To: =?UTF-8?B?SsOpcsOpbXkgTGVmYXVyZQ==?= <jeremy.lefaure@lse.epita.fr>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

--===============0646744013==
Content-Type: multipart/alternative; boundary="001a11c1601e721592055a9362af"

--001a11c1601e721592055a9362af
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Thanks for the patch! :)

2017-10-01 22:30 GMT+03:00 J=C3=A9r=C3=A9my Lefaure <jeremy.lefaure@lse.epi=
ta.fr>:

> Hi everyone,
> Using ARRAY_SIZE improves the code readability. I used coccinelle (I
> made a change to the array_size.cocci file [1]) to find several places
> where ARRAY_SIZE could be used instead of other macros or sizeof
> division.
>
> I tried to divide the changes into a patch per subsystem (excepted for
> staging). If one of the patch should be split into several patches, let
> me know.
>
> In order to reduce the size of the To: and Cc: lines, each patch of the
> series is sent only to the maintainers and lists concerned by the patch.
> This cover letter is sent to every list concerned by this series.
>
> This series is based on linux-next next-20170929. Each patch has been
> tested by building the relevant files with W=3D1.
>
> This series contains the following patches:
> [PATCH 01/18] sound: use ARRAY_SIZE
> [PATCH 02/18] tracing/filter: use ARRAY_SIZE
> [PATCH 03/18] media: use ARRAY_SIZE
> [PATCH 04/18] IB/mlx5: Use ARRAY_SIZE
> [PATCH 05/18] net: use ARRAY_SIZE
> [PATCH 06/18] drm: use ARRAY_SIZE
> [PATCH 07/18] scsi: bfa: use ARRAY_SIZE
> [PATCH 08/18] ecryptfs: use ARRAY_SIZE
> [PATCH 09/18] nfsd: use ARRAY_SIZE
> [PATCH 10/18] orangefs: use ARRAY_SIZE
> [PATCH 11/18] dm space map metadata: use ARRAY_SIZE
> [PATCH 12/18] x86: use ARRAY_SIZE
> [PATCH 13/18] tpm: use ARRAY_SIZE
> [PATCH 14/18] ipmi: use ARRAY_SIZE
> [PATCH 15/18] acpi: use ARRAY_SIZE
> [PATCH 16/18] media: staging: atomisp: use ARRAY_SIZE
> [PATCH 17/18] staging: rtl8723bs: use ARRAY_SIZE
> [PATCH 18/18] staging: rtlwifi: use ARRAY_SIZE
>
>
> [1]: https://lkml.org/lkml/2017/9/13/689
> _______________________________________________
> Intel-gfx mailing list
> Intel-gfx@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/intel-gfx
>

--001a11c1601e721592055a9362af
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Thanks for the patch! :)<div class=3D"gmail_extra"><br><di=
v class=3D"gmail_quote">2017-10-01 22:30 GMT+03:00 J=C3=A9r=C3=A9my Lefaure=
 <span dir=3D"ltr">&lt;<a href=3D"mailto:jeremy.lefaure@lse.epita.fr" targe=
t=3D"_blank">jeremy.lefaure@lse.epita.fr</a>&gt;</span>:<br><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pa=
dding-left:1ex">Hi everyone,<br>
Using ARRAY_SIZE improves the code readability. I used coccinelle (I<br>
made a change to the array_size.cocci file [1]) to find several places<br>
where ARRAY_SIZE could be used instead of other macros or sizeof<br>
division.<br>
<br>
I tried to divide the changes into a patch per subsystem (excepted for<br>
staging). If one of the patch should be split into several patches, let<br>
me know.<br>
<br>
In order to reduce the size of the To: and Cc: lines, each patch of the<br>
series is sent only to the maintainers and lists concerned by the patch.<br=
>
This cover letter is sent to every list concerned by this series.<br>
<br>
This series is based on linux-next next-20170929. Each patch has been<br>
tested by building the relevant files with W=3D1.<br>
<br>
This series contains the following patches:<br>
[PATCH 01/18] sound: use ARRAY_SIZE<br>
[PATCH 02/18] tracing/filter: use ARRAY_SIZE<br>
[PATCH 03/18] media: use ARRAY_SIZE<br>
[PATCH 04/18] IB/mlx5: Use ARRAY_SIZE<br>
[PATCH 05/18] net: use ARRAY_SIZE<br>
[PATCH 06/18] drm: use ARRAY_SIZE<br>
[PATCH 07/18] scsi: bfa: use ARRAY_SIZE<br>
[PATCH 08/18] ecryptfs: use ARRAY_SIZE<br>
[PATCH 09/18] nfsd: use ARRAY_SIZE<br>
[PATCH 10/18] orangefs: use ARRAY_SIZE<br>
[PATCH 11/18] dm space map metadata: use ARRAY_SIZE<br>
[PATCH 12/18] x86: use ARRAY_SIZE<br>
[PATCH 13/18] tpm: use ARRAY_SIZE<br>
[PATCH 14/18] ipmi: use ARRAY_SIZE<br>
[PATCH 15/18] acpi: use ARRAY_SIZE<br>
[PATCH 16/18] media: staging: atomisp: use ARRAY_SIZE<br>
[PATCH 17/18] staging: rtl8723bs: use ARRAY_SIZE<br>
[PATCH 18/18] staging: rtlwifi: use ARRAY_SIZE<br>
<br>
<br>
[1]: <a href=3D"https://lkml.org/lkml/2017/9/13/689" rel=3D"noreferrer" tar=
get=3D"_blank">https://lkml.org/lkml/2017/9/<wbr>13/689</a><br>
______________________________<wbr>_________________<br>
Intel-gfx mailing list<br>
<a href=3D"mailto:Intel-gfx@lists.freedesktop.org">Intel-gfx@lists.freedesk=
top.<wbr>org</a><br>
<a href=3D"https://lists.freedesktop.org/mailman/listinfo/intel-gfx" rel=3D=
"noreferrer" target=3D"_blank">https://lists.freedesktop.org/<wbr>mailman/l=
istinfo/intel-gfx</a><br>
</blockquote></div><br></div></div>

--001a11c1601e721592055a9362af--

--===============0646744013==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KSW50ZWwtZ2Z4
IG1haWxpbmcgbGlzdApJbnRlbC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBzOi8vbGlz
dHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vaW50ZWwtZ2Z4Cg==

--===============0646744013==--
