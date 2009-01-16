From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [ANNOUNCE] iproute2 v2.6.28
Date: Fri, 16 Jan 2009 09:43:17 -0800
Message-ID: <20090116094317.71bd535a@extreme>
References: <20090115130845.01d7ebf4@extreme>
	<200901161546.34691.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53911 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757185AbZAPRnT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 12:43:19 -0500
In-Reply-To: <200901161546.34691.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> There was no 2.6.27 release, so please include changelog up to 2.6.26=
=2E

Alexander Duyck (2):
      add support for skbedit action
      add support for multiq qdisc

Andreas Henriksson (5):
      fix syntax errors in ip(8) manpage.
      ip: abbreviation of network-prefix is no longer possible with ip =
route
      ip a flush: unnecessarily chatty when there's nothing to flush
      iproute: DESTDIR vs LIBDIR.
      Allow he in tunnel name

Benedikt Gollatz (1):
      Fix IPV6 autoconfig causing negative preferred lifetime

Denys Fedoryshchenko (2):
      long/ulong iproute-git fix
      Fix tc/m_ipt memory leaks

Herbert Xu (3):
      ip: xfrm: Add AEAD support
      ip: gre: Add GRE configuration support through rtnl_link
      Update version of IP gre

Jussi Kivilinna (1):
      add generic size table for qdiscs

Li Yewang (2):
      Fix the error of "ss -f inet -t"
      distinguish the inet and inet6 domain when loading the tcp_diag m=
odule

Olivier Fourdan (1):
      ip maddr show=E2=80=9D on an infiniband address causes a stack co=
rruption

Patrick McHardy (4):
      cls_flow: add perturbation support
      iflink_vlan: support GVRP flag
      Support "ip link add help" for rtnl_link API
      Refuse "ip link add/replace" without device type parameter

Stephen Hemminger (19):
      Revert "I found out when I was writing manual page, that options =
ALGO_NAME and"
      Add DSCP values for RFC2597
      Update headers to 2.6.27
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/shemminger/iproute2
      Update to 2.6.27 API
      Merge in fix for loss of MQ
      Fix duplicate return
      tc filter help should just print usage
      Fix help text for ip link
      Compatiable network abbreviation support
      Restore old address parsing but with checking
      Update headers to 2.6.28
      Fix leftovers from earlier change
      Fix compile warnings
      Update snapshot


