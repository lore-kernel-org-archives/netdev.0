From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Problems with TCP + netem packet loss simulation
Date: Thu, 11 Nov 2004 15:28:34 -0800
Message-ID: <20041111152834.5a7b1f79@dxpl.pdx.osdl.net>
References: <200411112115.23269.epx@altoriopreto.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Elvis =?ISO-8859-1?B?UGb8dHplbnJldXRlcg==?= <epx@altoriopreto.com.br>
In-Reply-To: <200411112115.23269.epx@altoriopreto.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Nov 2004 21:15:23 -0200
Elvis Pf=FCtzenreuter <epx@altoriopreto.com.br> wrote:

> Hi,
>=20
> I am experiencing a strange problem when I try to simulate a lossy chan=
nel=20
> with netem scheduler module. Whatever the packet loss %, all TCP connec=
tions=20
> eventually stall.=20

Netem might be buggy, try doing lots of pings and see if the rate you
expected is correct.  The scaling of percent to u32 is probably the issue.
