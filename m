From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Thu, 8 Jan 2009 12:22:17 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0901081057430.10976@tundra.namei.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <1231307334-9542-2-git-send-email-michael@laptop.org> <20090107114703.GB28161@ioremap.net> <20090107210758.GH3164@didacte.laptop.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090107210758.GH3164@didacte.laptop.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[added lsm list to the cc]

> Daniel Bernstein has observed [1] that security-conscious userland 
> processes may benefit from the ability to irrevocably remove their 
> ability to  create, bind, connect to, or send messages except in the 
> case of previously connected sockets or AF_UNIX filesystem sockets. We 
> provide this facility by implementing support for a new rlimit called 
> RLIMIT_NETWORK.
> 
> This facility is particularly attractive to security platforms like OLPC
> Bitfrost [2] and to isolation programs like Rainbow [3] and Plash [4].
> 
> [1]: http://cr.yp.to/unix/disablenetwork.html
> [2]: http://wiki.laptop.org/go/OLPC_Bitfrost
> [3]: http://wiki.laptop.org/go/Rainbow
> [4]: http://plash.beasts.org/

Have you considered utilizing network namespaces [1] ?  A process created 
with a private network namespace has no network interfaces configured, 
except loopback, which is down.  Does this do what you want?  The launcher 
could optionally allow local IP by bringing up the loopback interface.

[1] http://lxc.sourceforge.net/network.php


- James
-- 
James Morris
<jmorris@namei.org>
