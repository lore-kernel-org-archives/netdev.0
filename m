From: Sebastian Moeller <moeller0@gmx.de>
Subject: how to figure out which device a given IFB is connected to
Date: Mon, 15 Sep 2014 16:37:30 +0200
Message-ID: <CBDE840F-96BA-4839-9774-86F72E99E964@gmx.de>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:65060 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752144AbaIOOhb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 10:37:31 -0400
Received: from u-089-d065.biologie.uni-tuebingen.de ([134.2.89.65]) by
 mail.gmx.com (mrgmx101) with ESMTPSA (Nemesis) id 0MF9WR-1XZnrV1Lzf-00GLpJ
 for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 16:37:30 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I hope I am directing this to the correct mailing list, otherwise pleas=
e excuse the distraction=85=20

I am trying to figure out a way to semi-automatically manage a set of I=
=46B devices for a number of network interfaces. Currently I have no pr=
oblem finding out if a given =93real=94 interfaces is connected to an I=
=46B:

root@nacktmulle:~# tc -s filter show parent ffff: dev ge00
filter protocol all pref 10 u32=20
filter protocol all pref 10 u32 fh 800: ht divisor 1=20
filter protocol all pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0=
 flowid 1:1=20
  match 00000000/00000000 at 0
	action order 1: mirred (Egress Redirect to device ifb1) stolen
 	index 47 ref 1 bind 1 installed 521 sec used 3 sec


I am looking for a way of doing the reverse,i.e.  figuring out for a gi=
ven IFB if it is =93connected=94 to a real interface and, if yes, which=
 interface. Basically, I want to recycle unused IFBs, but want to make =
sure that they really are unused=85

Thanks in advance
	Sebastian Moeller