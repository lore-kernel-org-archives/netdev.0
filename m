From: Patrick Schaaf <netdev@bof.de>
Subject: Re: RFC: pid "ownership" of ip config information
Date: Sun, 23 Jan 2011 11:24:31 +0100
Message-ID: <1295778271.5657.7.camel@lat1>
References: <1295602091.3582.1.camel@lat1>  <4D395D3C.9010308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bof-2.saar.de ([192.109.53.146]:45186 "EHLO oknodo.bof.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211Ab1AWKYg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 05:24:36 -0500
In-Reply-To: <4D395D3C.9010308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-01-21 at 11:17 +0100, Nicolas de Peslo=C3=BCan wrote:
> Le 21/01/2011 10:28, Patrick Schaaf a =C3=A9crit :
> > The alternative to such a feature, would be to have an additional
> > monitoring process, which would watch the PID somehow, and need to
> > be configured to know what to withdraw when it dies.

> There exists some user space clustering system that should provide th=
e same functionalities. Did you=20
> had a look at http://www.linux-ha.org/ ?

Those would be the more complex instances of "an additional monitoring
process", right?

What happens when heartbeat is "kill -9"ed? Assume that I want to avoid
STOMITH like approaches.

My proposal could be _used_ by such complex clustering managers, too.

Or, did I overlook there a kernel based solution to "withdraw IP config
when processes die"? Can you provide a direct link on linux-ha?

best regards
  Patrick

