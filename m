From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] Makefile: Document ability to make file.lst and file.S
Date: Thu, 14 Jan 2010 11:26:01 +0800
Message-ID: <2375c9f91001131926o15a52e1cx936932c587dccdb5@mail.gmail.com>
References: <4B49D001.4000302@gmail.com> <4B4DA4F4.6060007@gmail.com>
	 <20100113115617.GA24818@basil.fritz.box> <4B4DE887.6030602@gmail.com>
	 <20100113155323.GB24818@basil.fritz.box>
	 <1263400835.8011.73.camel@Joe-Laptop.home>
	 <20100113171411.GC24818@basil.fritz.box>
	 <1263403904.8011.83.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, Michal Marek <mmarek@suse.cz>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kbuild@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1263403904.8011.83.camel@Joe-Laptop.home>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 14, 2010 at 1:31 AM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2010-01-13 at 18:14 +0100, Andi Kleen wrote:
>> On Wed, Jan 13, 2010 at 08:40:35AM -0800, Joe Perches wrote:
>> > On Wed, 2010-01-13 at 16:53 +0100, Andi Kleen wrote:
>> > > On Wed, Jan 13, 2010 at 10:36:39AM -0500, William Allen Simpson =
wrote:
>> > > > What make command would you suggest to get the interleaved asm=
?
>> > > make path/to/file.lst
>> > > (or .S -- you might need uptodate binutils if the lst listing is=
 messed up)
>> > I didn't know that was possible.
>> The trap is that it doesn't work well on most systems with too
>> old binutils (unless the gcc is really ancient)
>
> Then that might as well go into the help.
>
> Signed-off-by: Joe Perches <joe@perches.com>

Good patch,

Acked-by: WANG Cong <xiyou.wangcong@gmail.com>

> ---
> diff --git a/Makefile b/Makefile
> index 9f64552..484cff4 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -1248,7 +1248,9 @@ help:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0@echo =C2=A0' =C2=A0firmware_install- Inst=
all all firmware to INSTALL_FW_PATH'
> =C2=A0 =C2=A0 =C2=A0 =C2=A0@echo =C2=A0' =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(default: $$(INSTALL_MOD_PATH)=
/lib/firmware)'
> =C2=A0 =C2=A0 =C2=A0 =C2=A0@echo =C2=A0' =C2=A0dir/ =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0- Build all files in dir and below'
> - =C2=A0 =C2=A0 =C2=A0 @echo =C2=A0' =C2=A0dir/file.[ois] =C2=A0- Bui=
ld specified target only'
> + =C2=A0 =C2=A0 =C2=A0 @echo =C2=A0' =C2=A0dir/file.[oisS] - Build sp=
ecified target only'
> + =C2=A0 =C2=A0 =C2=A0 @echo =C2=A0' =C2=A0dir/file.lst =C2=A0 =C2=A0=
- Build specified mixed source/assembly target only'
> + =C2=A0 =C2=A0 =C2=A0 @echo =C2=A0' =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(requires a recent binutils and rece=
nt build (System.map))'
> =C2=A0 =C2=A0 =C2=A0 =C2=A0@echo =C2=A0' =C2=A0dir/file.ko =C2=A0 =C2=
=A0 - Build module including final link'
> =C2=A0 =C2=A0 =C2=A0 =C2=A0@echo =C2=A0' =C2=A0modules_prepare - Set =
up for building external modules'
> =C2=A0 =C2=A0 =C2=A0 =C2=A0@echo =C2=A0' =C2=A0tags/TAGS =C2=A0 =C2=A0=
 =C2=A0 - Generate tags file for editors'
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>
--
To unsubscribe from this list: send the line "unsubscribe linux-kbuild"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
