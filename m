From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [RFC 2/3] =?UTF-8?Q?if=5Fether=2Eh=3A=20Add=20IEEE=20=38=30=32=2E=31?=
 =?UTF-8?Q?=20Local=20Experimental=20Ethertype=20=31=2E?=
Date: Thu, 01 Dec 2011 08:13:57 +0100
Message-ID: <5636a5efd90c56b538569ab019d7be4c@chewa.net>
References: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com> <1322685846-7790-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:38904 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751201Ab1LAHN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 02:13:59 -0500
In-Reply-To: <1322685846-7790-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Nov 2011 21:44:05 +0100, Sjur Br=EF=BF=BD=EF=BF=BDndeland=0D
<sjur.brandeland@stericsson.com> wrote:=0D
> From: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>=0D
> =0D
> Add EthType 0x88b5.=0D
> This Ethertype value is available for public use for prototype and=0D
> vendor-specific protocol development,as defined in Amendment 802a=0D
> to IEEE Std 802.=0D
=0D
I don't think you can just go and steal a reserved EtherType. What if s=
ome=0D
user-space (using packet sockets) or out-of-tree kernel driver does act=
ual=0D
"experiment" with this type?=0D
=0D
Why don't you define your own link-layer, e.g. with a vendor-specific C=
DC=0D
profile?=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net/
