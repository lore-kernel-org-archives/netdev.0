From: Pavel Simerda <psimerda@redhat.com>
Subject: Kernel doesn't propagate DNSSL to userspace (e.g. NetworkManager)
Date: Wed, 23 May 2012 04:16:17 -0400 (EDT)
Message-ID: <fb24ca84-9976-42ab-b81a-73955b753731@zmail19.collab.prod.int.phx2.redhat.com>
References: <0263d6e6-50ba-4101-b958-260e2948c4ab@zmail19.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <danwilli@redhat.com>, danw@gnome.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:58743 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756004Ab2EWIQ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 04:16:27 -0400
In-Reply-To: <0263d6e6-50ba-4101-b958-260e2948c4ab@zmail19.collab.prod.int.phx2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I filed a bugreport to about lack of DNSSL support in kernel:

https://bugzilla.redhat.com/show_bug.cgi?id=3D824121

While NetworkManager recieves RDNSS neighbor discovery user option from=
 kernel, it doesn't recieve DNSSL at all. This can be debugged with Net=
workManager
(or hopefully some better testing tool) and radvdump (to check if DNSSL=
 is present).

radvdump reports DNSSL is there, NetworkManager gets no netlink message=
 from kernel.

kernel-3.3.4-4.fc17.x86_64
NetworkManager-0.9.4.0-7.git20120403.fc17.x86_64

Dave Jones asked me to contact this ML directly. I'm offlist.

Cheers,

Pavel =C5=A0imerda
