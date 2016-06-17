From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 1/3] Use C99 style initializers everywhere
Date: Fri, 17 Jun 2016 11:57:53 -0700
Message-ID: <20160617115753.6205562d@xeon-e3>
References: <1466178968-27439-1-git-send-email-phil@nwl.cc>
	<1466178968-27439-2-git-send-email-phil@nwl.cc>
	<ddef688e6e3f4a1a895880de1f9f069d@HQ1WP-EXMB11.corp.brocade.com>
	<20160617093401.24ae66b1@xeon-e3>
	<5764295E.7070103@iogearbox.net>
	<9e1c05c7b4894137a80bdb3d2a361bbc@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <daniel@iogearbox.net>, Phil Sutter <phil@nwl.cc>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"julien.floret@6wind.com" <julien.floret@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:30234 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753466AbcFQS6B convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 14:58:01 -0400
In-Reply-To: <9e1c05c7b4894137a80bdb3d2a361bbc@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Jun 2016 16:58:14 +0000
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Le 17/06/2016 18:46, Daniel Borkmann a =C3=A9crit :
> > On 06/17/2016 06:34 PM, Stephen Hemminger wrote:
> >> On Fri, 17 Jun 2016 16:09:20 +0000
> >> Daniel Borkmann <daniel@iogearbox.net> wrote:
> >>
> >>> Please have a look at commit 8f80d450c3cb ("tc: fix compilation w=
ith old gcc
> >>> (< 4.6)") ...
> >>>
> >>> Your changes effectively revert them again. Here, and some other =
parts of the
> >>> bpf frontend
> >>> code bits.
> >>
> >> GCC 4.6 is 3 years old. So perhaps it is time to move on.
> >> Maybe add a GCC version check in the makefile, to fail cleanly.
> >=20
> > Well, you don't have to ask me but rather the patch submitters (Cc)=
=2E
> >=20
> > I haven't used RHEL in quite a while, but I could imagine it might
> > be related to built it there perhaps.
> Yes. For some specific arch, we have only old toolchains.
>=20
> The rule was always to be backward compatible with old kernels. It im=
plies to
> also support the compilation with old toolchains ;-)

It makes sense that if you can build a kernel with old toolchain, that
iproute2 needs to be buildable as well.

The current kernels are documented to require 3.2 or later.
