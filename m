From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: drop association of connection-less socket
Date: Wed, 19 Sep 2007 08:04:57 -0700
Message-ID: <46F13A99.7090208@redhat.com>
References: <46F0CFB9.30808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44381 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754437AbXISPFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 11:05:05 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l8JF54Q9029965
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 11:05:04 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l8JF53v2001368
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 11:05:03 -0400
Received: from myware66.akkadia.org (vpn-14-92.rdu.redhat.com [10.11.14.92])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id l8JF53Ke011833
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 11:05:03 -0400
In-Reply-To: <46F0CFB9.30808@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

I guess the request is not that useful.  The family of the socket is
determined earlier so to undo this it takes more of an effort.  I
managed to get by for most cases without this change so no action neede=
d.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFG8TqZ2ijCOnn/RHQRAkXeAJ0RGW9zuP8xnLNVdnsHCLFR6IVJ8QCgwmBf
0ncI+FkqHE3vaYieIcHqOXo=3D
=3DUxXC
-----END PGP SIGNATURE-----
