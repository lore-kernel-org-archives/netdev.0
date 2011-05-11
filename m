From: Florian Weimer <fweimer@bfk.de>
Subject: Re: [PATCH 2/2] net/dl2k: Don't reconfigure link @100Mbps when disabling autoneg @1Gbps
Date: Wed, 11 May 2011 09:47:16 +0000
Message-ID: <82y62dk1qz.fsf@mid.bfk.de>
References: <1304986748-15809-1-git-send-email-decot@google.com>
	<1304986748-15809-3-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Decotigny <decot@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.bfk.de ([193.227.124.2]:34809 "EHLO mx01.bfk.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818Ab1EKSYv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 14:24:51 -0400
In-Reply-To: <1304986748-15809-3-git-send-email-decot@google.com> (David
	Decotigny's message of "Mon, 9 May 2011 17:19:08 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Decotigny:

> Tested: module compiling, NOT tested on real hardware.

To my knowledge, dl2k is broken.  Some sort of synchronization
primitives are missing.  Under load, the NIC's notion of ring buffer
status diverges from the host's view. 8-(

--=20
=46lorian Weimer                <fweimer@bfk.de>
BFK edv-consulting GmbH       http://www.bfk.de/
Kriegsstra=DFe 100              tel: +49-721-96201-1
D-76133 Karlsruhe             fax: +49-721-96201-99
