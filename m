From: Cong Wang <cwang@twopensource.com>
Subject: Re: next-timestamp build failure with 3.19-rc2
Date: Tue, 6 Jan 2015 12:04:13 -0800
Message-ID: <CAHA+R7OPJp9ayT6_zN6MxJd8arZyB4WGJ_3_pggwvTkwL9P2+w@mail.gmail.com>
References: <CAHTgTXUGVkJX26bFSOC9EH2gUynSKhLNr7D8mN8cSy7Km_+f9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jonathan Corbet <corbet@lwn.net>,
	"David S. Miller" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Vinson Lee <vlee@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHTgTXUGVkJX26bFSOC9EH2gUynSKhLNr7D8mN8cSy7Km_+f9Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 5, 2015 at 11:55 AM, Vinson Lee <vlee@twopensource.com> wro=
te:
> Hi.
>
> I'm hitting the following build error with 3.19-rc2 on CentOS 5 with
> glibc-headers-2.5-123.
>
>   HOSTCC  Documentation/networking/timestamping/txtimestamp
> Documentation/networking/timestamping/txtimestamp.c:64:8: error:
> redefinition of =E2=80=98struct in6_pktinfo=E2=80=99
>  struct in6_pktinfo {
>         ^
> In file included from /usr/include/arpa/inet.h:23:0,
>                  from Documentation/networking/timestamping/txtimesta=
mp.c:33:
> /usr/include/netinet/in.h:456:8: note: originally defined here
>  struct in6_pktinfo
>         ^

We need the same workaround as we did for in6_addr etc..
I am working on a patch now.
