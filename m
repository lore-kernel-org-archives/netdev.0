From: "Naveen B N (nbn)" <nbn@cisco.com>
Subject: Compile xfrm has module
Date: Wed, 22 Feb 2012 15:03:54 +0530
Message-ID: <A2354B6A9F807641B21EEABD666ECEEA02B81E4B@XMB-BGL-416.cisco.com>
References: <A2354B6A9F807641B21EEABD666ECEEA02B81E31@XMB-BGL-416.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-2.cisco.com ([72.163.197.26]:16833 "EHLO
	bgl-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab2BVJd5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 04:33:57 -0500
Received: from xbh-bgl-412.cisco.com (xbh-bgl-412.cisco.com [72.163.129.202])
	by bgl-core-4.cisco.com (8.14.3/8.14.3) with ESMTP id q1M9XtZX004655
	for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 09:33:55 GMT
Content-class: urn:content-classes:message
In-Reply-To: <A2354B6A9F807641B21EEABD666ECEEA02B81E31@XMB-BGL-416.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi=20
I am trying to compile xfrm has modules that can be inserted during run=
 time ,=20
I am able to compile but compile it But I found there are few issue ins=
erting the modules.
I have edited the Make file in net/xfrm to refelect the below , there a=
re few undefined references .
Is it polible to build XFRM itself has a module , please guide me on th=
e same.

root@qabng249c:/usr/src/linux-2.6.34# cat net/xfrm/Makefile
#
# Makefile for the XFRM subsystem.
#

obj-m :=3D xfrm_policy.o xfrm_state.o xfrm_hash.o \
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 xfrm_in=
put.o xfrm_output.o xfrm_algo.o \
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 xfrm_sy=
sctl.o
obj-n +=3D xfrm_proc.o
obj-m +=3D xfrm_user.o
obj-m +=3D xfrm_ipcomp.o

Thanks and Regards
Naveen
