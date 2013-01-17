From: Jike Song <albcamus@gmail.com>
Subject: Re: [libvirt] Redefinition of struct in6_addr in <netinet/in.h> and
	<linux/in6.h>
Date: Thu, 17 Jan 2013 11:55:41 +0800
Message-ID: <CANE52KhF17WRZTUbrjRDnwcbdN+V+69=ZqXjBwPjnswEO5iz7g@mail.gmail.com>
References: <201301161205.04502.vapier@gentoo.org>
	<1358356211.2923.25.camel@bwh-desktop.uk.solarflarecom.com>
	<201301161228.42592.vapier@gentoo.org>
	<20130116.135959.90676245194307972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4923491559353556289=="
Cc: libc-alpha@sourceware.org, amwang@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        libvirt-list@redhat.com, tgraf@suug.ch, carlos@systemhalted.org,
        schwab@suse.de, bhutchings@solarflare.com, vapier@gentoo.org,
        tmb@mageia.org
To: David Miller <davem@davemloft.net>
Return-path: <libvir-list-bounces@redhat.com>
In-Reply-To: <20130116.135959.90676245194307972.davem@davemloft.net>
List-Unsubscribe: <https://www.redhat.com/mailman/options/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/libvir-list>
List-Post: <mailto:libvir-list@redhat.com>
List-Help: <mailto:libvir-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=subscribe>
Sender: libvir-list-bounces@redhat.com
Errors-To: libvir-list-bounces@redhat.com
List-Id: netdev.vger.kernel.org

--===============4923491559353556289==
Content-Type: multipart/alternative; boundary=20cf3071d1daf9798c04d373f7b8

--20cf3071d1daf9798c04d373f7b8
Content-Type: text/plain; charset=UTF-8

On Thu, Jan 17, 2013 at 2:59 AM, David Miller <davem@davemloft.net> wrote:

>
> When GLIBC doesn't provide it's own definition of some networking
> macros or interfaces that the kernel provides, people include the
> kernel header.
>

Recently I got a problem when copying a structure from kernel to userspace,
after debugging I found:

kernel:   include/linux/inet.h

#define INET6_ADDRSTRLEN        (48)

glibc:  /usr/include/netinet/in.h

#define INET6_ADDRSTRLEN 46


Any reason to differentiate them from each other?

-- 
Thanks,
Jike

--20cf3071d1daf9798c04d373f7b8
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 17, 2013 at 2:59 AM, David Miller <span dir=3D"ltr">&lt;<a href=
=3D"mailto:davem@davemloft.net" target=3D"_blank">davem@davemloft.net</a>&g=
t;</span> wrote:<br><div class=3D"gmail_quote"><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x">

<div><br>
</div>When GLIBC doesn&#39;t provide it&#39;s own definition of some networ=
king<br>
macros or interfaces that the kernel provides, people include the<br>
kernel header.<br></blockquote><div><br></div><div>Recently I got a problem=
 when copying a structure from kernel to userspace, after debugging I found=
:</div><div><br></div><div>kernel:=C2=A0<span style=3D"color:rgb(34,34,34);=
font-size:13px;white-space:nowrap;font-family:arial,sans-serif">=C2=A0</spa=
n>=C2=A0include/linux/inet.h</div>

<div><br></div><div>#define INET6_ADDRSTRLEN =C2=A0 =C2=A0 =C2=A0 =C2=A0(48=
)</div><div><br></div><div>glibc: =C2=A0/usr/include/netinet/in.h</div><div=
><br></div><div><font color=3D"#222222" face=3D"arial, sans-serif"><span st=
yle=3D"white-space:nowrap">#define INET6_ADDRSTRLEN 46</span></font></div>

</div><div><br></div><div><br></div><div>Any reason to differentiate them f=
rom each other?</div><div><br></div>-- <br>Thanks,<br>Jike

--20cf3071d1daf9798c04d373f7b8--


--===============4923491559353556289==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============4923491559353556289==--
