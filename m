From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 34182] New: Hard hang arising from TCP/IP
 related bug in 2.6.39-rc4
Date: Sun, 1 May 2011 10:42:12 -0700
Message-ID: <20110501104212.273a9726.akpm@linux-foundation.org>
References: <bug-34182-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, htmldeveloper@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46324 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753458Ab1EARhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2011 13:37:17 -0400
In-Reply-To: <bug-34182-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 1 May 2011 17:32:07 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=34182
> 
>            Summary: Hard hang arising from TCP/IP related bug in
>                     2.6.39-rc4
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.39-rc4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: htmldeveloper@gmail.com
>         Regression: No
> 
> 
> Created an attachment (id=56082)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=56082)
> kernel crash log via dmesg
> 
> I did a git-update of linus git tree on 27 Apr 2011, built the new kernel
> image.   Ever since using the new image, I have been *consistently* getting
> many crashes - especially whenever my google chrome is retoring all its
> previous session connection.   
> 
> Two crashes (entire system freezes) are shown in attachment.   Ever since I
> have revert to previous version - as booting up twice and consistently twice it
> will fail within a few minutes after Chrome is used.
> 
> v2.6.39-rc4-245-g4175242
> 
> Previously working version:   2.6.38-rc2+.   Did not test anything between
> 2.6.38-rc2+ and 2.6.39-rc3, and 2.6.39-rc3 failed for me in other ways as well.
> 
> (http://bugzilla.kernel.org/show_bug.cgi?id=33272)
> 

