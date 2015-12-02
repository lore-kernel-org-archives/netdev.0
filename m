From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] i40e: Fix i40e_print_features() VEB mode output
Date: Wed, 02 Dec 2015 13:09:16 -0800
Message-ID: <1449090556.3716.61.camel@perches.com>
References: <1449045535.3716.10.camel@perches.com>
	 <1449050215.3224.29.camel@intel.com> <1449051149.3716.20.camel@perches.com>
	 <20151202.154800.1567031979226825020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	shannon.nelson@intel.com, Junio C Hamano <gitster@pobox.com>
To: David Miller <davem@davemloft.net>, patchwork@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0009.hostedemail.com ([216.40.44.9]:52519 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754334AbbLBVJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 16:09:20 -0500
In-Reply-To: <20151202.154800.1567031979226825020.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-02 at 15:48 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com> 02 Dec 2015 02:12:29 -0800
> > On Wed, 2015-12-02 at 01:56 -0800, Jeff Kirsher wrote:
> >> On Wed, 2015-12-02 at 00:38 -0800, Joe Perches wrote:
> >> > Noticed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>=
=A0
> >> Don't you mean Reported-by? =A0I am not aware of Noticed-by as bei=
ng a
> >> recognized signature.=A0
> > At least for the get_maintainer script, "-by:" is a signature
> Is patchwork using the same regexp?=A0 If not, for the time being don=
't
> user non-standard tags, and furthermore please ask the patchwork folk=
s
> to use something similar to getmaintainer.pl

It doesn't seem so.

=A0=A0=A0=A0response_re =3D re.compile(
=A0=A0=A0=A0=A0=A0=A0=A0r'^(Tested|Reviewed|Acked|Signed-off|Nacked|Rep=
orted)-by: .*$',
=A0=A0=A0=A0=A0=A0=A0=A0re.M | re.I)

patchwork also doesn't seem very forgiving of misformatted signatures.
(btw: Junio Hamano seems to prefer calling them trailers)

And patchwork doesn't seem to handle "cc: " markers either.
