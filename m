From: John Richard Moser <nigelenki@comcast.net>
Subject: Re: Sockets from kernel space?
Date: Wed, 15 Dec 2004 22:15:06 -0500
Message-ID: <41C0FDBA.5060406@comcast.net>
References: <41C0E720.8050201@comcast.net> <41C0DF8B.2020007@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261916AbULPDO1@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41C0DF8B.2020007@conectiva.com.br>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Thanks.  I'll look at those.

I'm aiming at potentially writing an LSM that allows a process to attach
to the kernel, which will then be sent messages through an AF_UNIX
(these are the app<->app sockets right?) socket with the details of any
listen(2) or connect(2) calls made.  I was going to do it in userspace,
but realized it was easily avoidable that way.

If this works, I can pretty much securely create a host firewall that
regulates based on network operations, user, and program.  This would
allow the creation of discressionary firewalls, like Zone Alarm, Norton
PF, McAffee PF, etc.  The daemon sits in userspace, the kernel asks it
for policy decisions, it asks connected/authenticated clients about
unknown policy, and makes them re-authenticate to get an answer.  The
authentication is in userspace (PAM), hence the daemon.

Arnaldo Carvalho de Melo wrote:
[...]
|
| Please send networking development related messages to netdev@oss.sgi.com,
| there are several networking hackers that don't even subscribe lkml.
|
| Having said that, look at the svc_makesock and svc_create_socket functions
| in net/sunrpc/svcsock.c as a starting point.
|
| - Arnaldo

- --
All content of all messages exchanged herein are left in the
Public Domain, unless otherwise explicitly stated.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBwP26hDd4aOud5P8RAhSjAJ956RdBt9deoh3RgW7UKWdEgNeLMACeOR+b
nVFR/uA/ZNXkv2b6HYcRczw=
=VUfC
-----END PGP SIGNATURE-----
