From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2] iproute2 question
Date: Thu, 18 Mar 2010 23:27:26 -0700
Message-ID: <20100318232726.47f800e1@nehalam>
References: <f4f837ab1003180202h6b2d5ed0ledd2a24dfd2627df@mail.gmail.com>
	<20100318085919.05328127@nehalam>
	<f4f837ab1003182253x12727855k118f7d67115daf23@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35935 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751470Ab0CSGeK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 02:34:10 -0400
In-Reply-To: <f4f837ab1003182253x12727855k118f7d67115daf23@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Mar 2010 13:53:23 +0800
thomas yang <lampsu@gmail.com> wrote:

> 2010/3/18 Stephen Hemminger <shemminger@vyatta.com>:
> > On Thu, 18 Mar 2010 17:02:16 +0800
> > thomas yang <lampsu@gmail.com> wrote:
> >
> >> Hi,
> >>
> >> Linux router R (has some interfaces) =C2=A0use the table "main" as=
 default
> >> routing table to route packets. =C2=A0If =C2=A0some link connected=
 to R failed,
> >> I want to use another table "backup_tbl" to route packets; if the
> >> broken link repaired , go back to use table "main" =C2=A0. =C2=A0H=
ow to do this?
> >
> > That's now it works. Use a real routing daemon.
> >
>=20
> I want to reduce the packet loss that happens while routers converge
> after a topology change due to a failure, use precalculated backup
> table to do rapid failure repair  (repair faster than routing daemon,
> fast reroute).
> I do static routing on my linux routers.  When  some link  failed,
>  I want to  use backup tables to route packets.  Can iproute2 do this=
?

You could probably kludge something with multiple route tables
and modifying a single 'ip rule'.
Something like:
   http://www.linuxhorizon.ro/iproute2.html
