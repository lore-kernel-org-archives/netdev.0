From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 41312] New: Regression: some web services
 (e.g. Dropbox, Amazon Cloud Reader) stops working in 3.1-rc2
Date: Wed, 17 Aug 2011 13:41:06 -0700
Message-ID: <20110817134106.015135cd.akpm@linux-foundation.org>
References: <bug-41312-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, salimma@fedoraproject.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54566 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754499Ab1HQUlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 16:41:12 -0400
In-Reply-To: <bug-41312-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 17 Aug 2011 20:17:05 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=41312
> 
>            Summary: Regression: some web services (e.g. Dropbox, Amazon
>                     Cloud Reader) stops working in 3.1-rc2
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.1-rc2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: salimma@fedoraproject.org
>         Regression: Yes
> 
> 
> Created an attachment (id=69102)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=69102)
> (working) config for kernel 3.0
> 
> Dropbox and Amazon Cloud Reader works just fine on kernel 3.0, but the former
> does not work on 3.1-rc1 and 3.1-rc2, and the latter does not work on 3.1-rc2
> (I no longer have a copy of the 3.1-rc1 build I did).
> 
> With Dropbox, ps reports that the daemon process is in an uninterruptible
> state, and it cannot be killed (even with kill -9). Setting SELinux to
> permissive does not affect things (and Dropbox works with SELinux set to
> enforcing with kernel 3.0).
> 
> With Cloud Reader, on Chrome, it does not display any book -- I perpetually get
> the "refreshing" icon.
> 
> Will attach kernel configurations (I keep the 3.0 and 3.1-rc2 configs as
> similar as possible, by using 'make oldconfig' on 3.0 with 3.1-rc2's .config.
> 
> Reported on Dropbox's forum: http://forums.dropbox.com/topic.php?id=43140
> 

