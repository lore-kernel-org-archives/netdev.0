From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: Sockets from kernel space?
Date: Thu, 16 Dec 2004 00:29:46 -0200
Message-ID: <41C0F31A.4050305@conectiva.com.br>
References: <41C0E720.8050201@comcast.net> <41C0DF8B.2020007@conectiva.com.br> <41C0FDBA.5060406@comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Richard Moser <nigelenki@comcast.net>
In-Reply-To: <41C0FDBA.5060406@comcast.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John Richard Moser wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Thanks.  I'll look at those.
> 
> I'm aiming at potentially writing an LSM that allows a process to attach
> to the kernel, which will then be sent messages through an AF_UNIX
> (these are the app<->app sockets right?) socket with the details of any
> listen(2) or connect(2) calls made.  I was going to do it in userspace,
> but realized it was easily avoidable that way.
> 
> If this works, I can pretty much securely create a host firewall that
> regulates based on network operations, user, and program.  This would
> allow the creation of discressionary firewalls, like Zone Alarm, Norton
> PF, McAffee PF, etc.  The daemon sits in userspace, the kernel asks it
> for policy decisions, it asks connected/authenticated clients about
> unknown policy, and makes them re-authenticate to get an answer.  The
> authentication is in userspace (PAM), hence the daemon.

Look at the iproute2 code to know how to use netlink 8)

- Arnaldo
