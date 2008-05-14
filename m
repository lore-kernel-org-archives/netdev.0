From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10694] New: Sis 191 not responding when
 mount.cifs
Date: Wed, 14 May 2008 10:26:28 -0700
Message-ID: <20080514102628.02115aa1.akpm@linux-foundation.org>
References: <bug-10694-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Steven French <sfrench@us.ibm.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: juanjo@apertus.es
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58565 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752959AbYENR0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 13:26:39 -0400
In-Reply-To: <bug-10694-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 14 May 2008 03:55:57 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10694
> 
>            Summary: Sis 191 not responding when mount.cifs
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.25.3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: juanjo@apertus.es
> 
> 
> Latest working kernel version: non
> Earliest failing kernel version: 2.6.24
> Distribution: Other
> Hardware Environment: Acer Extensa E261 (SIS191 on ISA bridge SIS968 with
> RLT8211BL transceiver)
> Software Environment: linux boot to allow an unattended installation.
> http://unattended.cvs.sourceforge.net/unattended/unattended/linuxboot/
> Problem Description: mounting a network share with mount.cfis gets an error
> about the server not responding. Modifying the mtu of the ethernet interface
> make it to work.
> 
> Steps to reproduce:
> 
> mount.cifs \\ntinstall\install /z -o "username=guest,ro,nocase"
> 
> An error on the Screen:
> --------------------------------------
> CIFS VFS: server not responding 
> CIFS VFS: No responde to cmd 46 mid 10
> --------------------------------------
> execute:
> ifconfig eth0 mtu 1942
> 
> Then the network share is accessible. And the error disappear.
> 

How strange.  Good detective work, btw.

Did we a) change the MTU size with 2.6.25 or b) break larger MTUs in 2.6.25?

Can you find out what the MTU size was with 2.6.24?  And what size is
the MTU in 2.6.25 before you reset it?

Thanks.
