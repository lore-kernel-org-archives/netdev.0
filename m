From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 40422] New: 3.0: kernel panic - not syncing: fatal
 exception in interrupt
Date: Mon, 1 Aug 2011 14:04:18 -0700
Message-ID: <20110801140418.510c5dc4.akpm@linux-foundation.org>
References: <bug-40422-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: mihai.dontu@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <bug-40422-27@https.bugzilla.kernel.org/>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 1 Aug 2011 20:51:43 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=40422
> 
>            Summary: 3.0: kernel panic - not syncing: fatal exception in
>                     interrupt
>            Product: Memory Management
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: mihai.dontu@gmail.com
>         Regression: No
> 
> 
> Upon resuming from suspend to disk, I got a kernel panic like it can be seen in
> the attached picture. I'm using 3.0 for less than a week and this is the first
> time this happens (after several successful suspend+resume-s).
> 

--- Comment #1 from Mihai Don#u <mihai.dontu@gmail.com>  2011-08-01 20:55:23 ---
Created an attachment (id=67322)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=67322)
kernel panic camera shot

drat, the first part of that crash scrolled off the screen or wasn't in
the photo.  I don't suppose it's possible to get that information?

Still, the oops is in netfilter code - a bad pointer dereference under
devinet_ioctl->masq_device_event.

