From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: =?UTF-8?Q?setsockopt=28IP=5FTOS=29=20being=20privileged=20or=20distin?=
 =?UTF-8?Q?ct=20capability=3F?=
Date: Tue, 06 Jul 2010 10:17:26 +0200
Message-ID: <839e715080d03a9334b4a66553cdfcd4@chewa.net>
References: <4C2F7A55.5090700@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Philip Prindeville <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:41148 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754021Ab0GFIR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jul 2010 04:17:27 -0400
In-Reply-To: <4C2F7A55.5090700@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


=0D
=0D
On Sat, 03 Jul 2010 11:58:45 -0600, Philip Prindeville=0D
<philipp_subx@redfish-solutions.com> wrote:=0D
> Does anyone else think that setsockopt(IP_TOS) should be a privileged=
=0D
> operation, perhaps using CAP_NET_ADMIN, or maybe even adding separate=
=0D
> granularity as CAP_NET_TOS?=0D
=0D
That's a terribly idea.=0D
Some applications do rely on this to set their TOS "correctly". If you=0D
don't want unprivileged applications to be able to affect the queuing=0D
policy, then don't use the TOS bits in your queuing policy - as simple =
as=0D
that.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

