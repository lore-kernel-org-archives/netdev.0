From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11649] New: Network don't work with SiS 900
 PCI Fast Ethernet. Mainly, I tried with DHCP interface. With exacly the
 same configurations network works on olders kernels and don't work on the
 newest
Date: Sat, 4 Oct 2008 03:33:58 -0700
Message-ID: <20081004033358.b3ea6500.akpm@linux-foundation.org>
References: <bug-11649-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, mateusz.pastewski@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52292 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752295AbYJDKeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 06:34:31 -0400
In-Reply-To: <bug-11649-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 25 Sep 2008 17:35:20 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11649
> 
>            Summary: Network don't work with SiS 900 PCI Fast Ethernet.
>                     Mainly, I tried with DHCP interface. With exacly the
>                     same configurations network works on olders kernels and
>                     don't work on the newest
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.26.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: mateusz.pastewski@gmail.com
> 
> 
> Latest working kernel version: 2.6.23.x
> Earliest failing kernel version: 2.6.24.x
> Distribution: Debian Etch 4.0
> Hardware Environment: PC
> Software Enviroment:
> Problem Description:
> 
> I installed Debian Etch 4.0 (with kernel 2.6.18-6-k7) on my machine with ECS
> K7S5A with built-in network card SIS900. During the installation and after
> first boot internet worked like a dream with auto configurated DHCP interface.
> But after change kernel to version 2.6.26.5 internet didn't work. In this
> moment I realized that I didn't change internet configurations, but I thought
> that it can be wrong in hardware configurations. On the other hand, the results
> by lspci and lspci -n, said that everything had worked perfectly. Then, I
> compiled kernel 2.6.26.5 with exacly the same .config file like kernel from
> debian distribution (2.6.18-6-k7) and internet didn't work too. After that, I
> compiled older kernel (2.6.17) with this .config file and internet started
> working! I think, it is proof that it is something wrong in module sis900 in
> the newest kernel versions, because I didn't change others system
> configurations!
> 
> What is more, system didn't have interrupt for ethernet, thought lspci
> recognized network card, sis900 module was started and DHCP was set. To confirm
> my view I attache interrupt's list and logs from internet starting/restarting:
>
> ...
>

A mystery regression in sis900.  There's quie a bit more info i te
bugzilla report.

