From: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
Subject: Re: Dead Config Option STMMAC_ETH?
Date: Mon, 23 Aug 2010 10:42:26 +0200
Message-ID: <86bp8tu3d9.fsf@peer.zerties.org>
References: <86r5i6vegw.fsf@peer.zerties.org>
	<107012446AC13D4C90B85672EAF5FB0E9E0FB3CC9C@SAFEX1MAIL3.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"vamos-dev\@i4.informatik.uni-erlangen.de"
	<vamos-dev@i4.informatik.uni-erlangen.de>
To: Peppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from peer.zerties.org ([188.40.33.175]:41324 "EHLO peer.zerties.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751688Ab0HWImd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 04:42:33 -0400
In-Reply-To: <107012446AC13D4C90B85672EAF5FB0E9E0FB3CC9C@SAFEX1MAIL3.st.com>
	(Peppe CAVALLARO's message of "Mon, 23 Aug 2010 09:13:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peppe CAVALLARO <peppe.cavallaro@st.com> writes:

[...]

> There is effort on this driver: currently the driver fully works on
> STM platforms and starts working on ARM (SPEAr Kernels).  The driver
> Kconfig actually depends on the CPU_SUBTYPE_ST40 but it built on x86
> if remove this dependency (just verified).  In the past, I added this
> dependency because the driver was initially tested on ST kernels
> (where we continue to have the CPU_SUBTYPE_ST40) but I can review it
> if you like.

Hm, i think it would be good if this dependency is removed, if it isn't
needed, because then a allyes config would compile test this peace of
code, and it can't die silently with changes around it.

greetz didi
--=20
(=CE=BB x . x x) (=CE=BB x . x x) -- See how beatiful the lambda is
No documentation is better than bad documentation
-- Das Ausdrucken dieser Mail wird urheberrechtlich verfolgt.
