From: Fan Du <fan.du@windriver.com>
Subject: [DISCUSSION] rt6i_genid
Date: Thu, 18 Jul 2013 11:22:42 +0800
Message-ID: <51E75F82.4080300@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:56096 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755878Ab3GRDW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 23:22:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Nicolas

Commit 6f3118b571b8a4c06c7985dc3172c3526cb86253: "ipv6: use net->rt_gen=
id to check dst validity"
makes ip6_dst_check to check rt6i_genid against with struct net->rt_gen=
id,
As a matter of fact, struct net->rt_genid could only be modified by two=
 places,
first is adding/delete IPv4 address, second is inserting new XFRM polic=
y.

Is there any other considerations that adding/deleting IPv4 address wou=
ld invalid all IPv6 dst
as well? because I'm working a patch which actually depends on the resu=
lt of this question.


Thanks

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
