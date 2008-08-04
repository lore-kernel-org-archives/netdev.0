From: "Leandro Oliveira da Silva" <lansoweb@hotmail.com>
Subject: RES: [Bugme-new] [Bug 11249] New: TC HTB hanging problem
Date: Mon, 4 Aug 2008 15:44:30 -0300
Message-ID: <BAY111-DAV13CEE254838554E11B28A0C0780@phx.gbl>
References: <bug-11249-10286@http.bugzilla.kernel.org/> <20080804105506.8b401320.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <bugme-daemon@bugzilla.kernel.org>
To: "'Andrew Morton'" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s14.bay0.hotmail.com ([65.54.246.150]:62471 "EHLO
	bay0-omc2-s14.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760361AbYHDSup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 14:50:45 -0400
In-Reply-To: <20080804105506.8b401320.akpm@linux-foundation.org>
Message-ID: <001201c8f662$214a3b40$63deb1c0$@com>
Content-Language: pt-br
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Andrew!

Just to add, 2 weeks ago one of my clients had to reboot the server 3 times
during the day, so I disabled the qos and it worked fine for 3 days. After
this days I started the qos again and 10 hours later the server hanged
again, so it's disabled until now without hanging.
Another info is that I got other server that was hanging randomly and put
the users using a router but kept the server on, in the internet and with
qos running and it doesn't hang in the last 10 days. So I guess it's not the
qos only, but something with qos and usage by users. I have other client
with same kernel, same rules running for more than 2 month and with more
than 4 times the internet usage than the others and it never hanged, so it's
not only high usage.
I really don't know what is happening.

Thanks a lot any advice,
Leandro

-----Mensagem original-----
De: Andrew Morton [mailto:akpm@linux-foundation.org] 
Enviada em: segunda-feira, 4 de agosto de 2008 14:55
Para: netdev@vger.kernel.org
Cc: bugme-daemon@bugzilla.kernel.org; lansoweb@hotmail.com
Assunto: Re: [Bugme-new] [Bug 11249] New: TC HTB hanging problem


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon,  4 Aug 2008 08:01:05 -0700 (PDT) bugme-daemon@bugzilla.kernel.org
wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11249
> 
>            Summary: TC HTB hanging problem
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.23 and 2.6.25
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: lansoweb@hotmail.com
> 
> 
> Latest working kernel version:
> Earliest failing kernel version: 2.6.23
> 
> Distribution: Mandriva 2007.1 and 2008.0
> 
> Hardware Environment:
> It happens in many different servers
> 
> Software Environment:
> Problem Description:
> I have close to 200 servers, most with mandriva 2006.0 using kernel
2.6.15,
> some with mandriva 2008.0 using kernel 2.6.23 or 2.6.25. In some of them
> (kernels 2.6.23 and 2.6.25 confirmed) the server hangs at random (some
servers
> hang more than once a day, some once a month).
> The hardware is different from each other and i have about 5 servers with
> exactly the same configuration (proc, mem, ethernet, so one) and one hangs
> every day while the others are running fine, all with the same rules for
> traffic shapping (tc using htb).
> I think that it is something related to tc because last week i accessed a
> server and when i type tc del to remove the shapping it hanged. My client
> restarted the server and about 10 minutes later i did it again with the
same
> effect. No kernel panic, no oops, just hangs. 
> I've read some posts and bugs but i see something related to ethernet
driver
> (like sk98lin), but it is happening with several servers with different
> hardwares.
> I have some servers with kernel 2.6.15 and, as far as i know, it doesn't
happen
> with them, but some of they use a different set of tc rules (a few less
rules
> actually) or none at all.
> I don't use the kernel shippied with mandriva distro, always got kernel
from
> kernel.org and compilled myself.
> 
> Steps to reproduce:
> Handly, since it is random, it takes minutes or weeks to happen, but
always
> with some change in tc (start or stop).


