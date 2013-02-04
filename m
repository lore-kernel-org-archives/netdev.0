From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iplink: display the value of IFLA_PROMISCUITY
Date: Mon, 4 Feb 2013 09:56:36 -0800
Message-ID: <20130204095636.64b57bd0@nehalam.linuxnetplumber.net>
References: <CB4696DA7737D0409230B481D0363B1414F0E60461@HQ1-EXCH03.corp.brocade.com>
	<20130204090419.2e351ac5@nehalam.linuxnetplumber.net>
	<510FEF97.7040903@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:40458 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833Ab3BDR4u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 12:56:50 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so915807pad.23
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 09:56:49 -0800 (PST)
In-Reply-To: <510FEF97.7040903@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 04 Feb 2013 18:27:51 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Le 04/02/2013 18:04, Stephen Hemminger a =E9crit :
> > On Mon, 28 Jan 2013 06:47:56 -0800
> > Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> >
> >> This is usefull to know the 'real' status of an interface (the fla=
g IFF_PROMISC
> >> is exported by the kernel only when the user set it explicitly, fo=
r example it
> >> will not be exported when a tcpdump is running).
> >>
> >> Note that I add a space after qlen (instead of before promiscuity)=
 to be
> >> coherent with the rest of the code.
> >>
> >> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> >> ---
> >>   ip/ipaddress.c | 5 ++++-
> >>   1 file changed, 4 insertions(+), 1 deletion(-)
> >
> > The idea is good, but I can't accept in the current form.
> > The problem with this is that it violates the unwritten assumption =
that the output
> > of ip command should be the arguments used to setup that interface.=
 There were even
> > some VPN's that depended on that.
> >
> Would it be acceptable to display this information when '-d' (ip -det=
ails link)=20
> is provided by the user?

Yeah, that seems to be where such things end up.
