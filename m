From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v2] soreuseport: add compat case for setsockopt SO_ATTACH_REUSEPORT_CBPF
Date: Sun, 5 Jun 2016 15:16:49 +0200
Message-ID: <CAF=yD-Lnr36p=nu6gsfA4sYZ8zE0y769_sf2utVC5AdbVGp+OA@mail.gmail.com>
References: <CAEfhGiwwvwf31Dj+s0zA0bpVAZ4x4=rLuU5g217u=wRrgm07Dg@mail.gmail.com>
 <20160603214002.GA58242@ast-mbp.thefacebook.com> <20160603214917.GA12557@ls3530.box>
 <57520291.7090004@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Helge Deller <deller@gmx.de>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Craig Gallek <kraigatgoog@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <57520291.7090004@iogearbox.net>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>
> [ Cc Willem: I believe we also need something similar for PACKET_FANOUT_DATA
>   when PACKET_FANOUT_CBPF is requested since we have the same issue with the
>   pointer in struct sock_fprog there, too. ]

Indeed. I'll send a patch in a few days (am traveling). Thanks for the
heads-up, Daniel.

(apologies if you also received an html version of this reply)
