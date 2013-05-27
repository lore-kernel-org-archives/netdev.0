From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [Patch net-next v9 00/11] vxlan: add ipv6 support
Date: Mon, 27 May 2013 10:57:04 +0200
Message-ID: <8761y4dcm7.fsf@nemi.mork.no>
References: <1369628193-14925-1-git-send-email-amwang@redhat.com>
	<87a9ngddfv.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54271 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751024Ab3E0I53 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 04:57:29 -0400
In-Reply-To: <87a9ngddfv.fsf@nemi.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Mon, 27
	May 2013 10:39:16 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> I see that you don't bother listen to advice.
>
>  ERROR: "nd_tbl" [drivers/net/vxlan.ko] undefined!


And building with CONFIG_IPV6=3Dm is even more fun:

ERROR: "in6addr_linklocal_allnodes" [net/ipv6/ipv6.ko] undefined!
ERROR: "in6addr_interfacelocal_allrouters" [net/ipv6/ipv6.ko] undefined=
!
ERROR: "in6addr_interfacelocal_allnodes" [net/ipv6/ipv6.ko] undefined!
ERROR: "in6addr_linklocal_allrouters" [net/ipv6/ipv6.ko] undefined!
ERROR: "in6addr_sitelocal_allrouters" [net/ipv6/ipv6.ko] undefined!
ERROR: "in6addr_any" [net/ipv6/ipv6.ko] undefined!
ERROR: "nd_tbl" [drivers/net/vxlan.ko] undefined!


Nice...


Bj=C3=B8rn
