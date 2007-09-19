From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 10:27:10 -0700
Message-ID: <46F15BEE.2050701@redhat.com>
References: <46F13E8B.4050309@redhat.com>	<p73sl5aveqh.fsf@bingen.suse.de>	<46F15305.2030507@redhat.com> <20070919.095251.45154496.davem@davemloft.net> <46F156A7.5000304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758341AbXISR1f@vger.kernel.org>
In-Reply-To: <46F156A7.5000304@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Ulrich Drepper wrote:
> Yes, but for IPv4/6 it's not an issue.  Some implementations might
> handle all-zeros and the spec _currently_ calls for it.  In this case=
 an
> alignment would be good.

Searching the web shows up this:

http://developer.apple.com/documentation/Darwin/Reference/ManPages/man2=
/connect.2.html


  Datagram sockets may dissolve the association by connecting to an
  invalid address, such as a null address or an address with the addres=
s
  family set to AF_UNSPEC (the error EAFNOSUPPORT will be harmlessly
  returned).


I.e., at least Apple implements both variants.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFG8Vvu2ijCOnn/RHQRAsSfAJkBELtiNyul8wMOjVv1x7LfvDWw/ACfR0D0
cm+k1wfhCsT4GjbF3uac+eY=3D
=3DnksN
-----END PGP SIGNATURE-----
