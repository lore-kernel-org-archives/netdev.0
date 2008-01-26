From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Sat, 26 Jan 2008 13:10:26 +0100
Message-ID: <20080126121026.GB2624@ami.dom.local>
References: <bug-9816-10286@http.bugzilla.kernel.org/> <20080125142603.a73fd7a2.akpm@linux-foundation.org> <479A6CBD.4010908@gmail.com> <20080125192026.e667f396.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, joonwpark81@gmail.com,
	bugme-daemon@bugzilla.kernel.org, schwab@suse.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:35443 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbYAZMHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 07:07:19 -0500
Received: by fg-out-1718.google.com with SMTP id e21so984745fga.17
        for <netdev@vger.kernel.org>; Sat, 26 Jan 2008 04:07:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080125192026.e667f396.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 25, 2008 at 07:20:26PM -0800, Andrew Morton wrote:
...
> That's not a very good analogy - the source is a kernel object.  A better
> example would be:
> 
> linux-2.6.24-rc8:
> 
> echo foo > /tmp/1
> echo bar > /tmp/2
> echo foo > /tmp/1
> 
> linux-2.6.24:
> 
> echo foo > /tmp/1
> echo bar > /tmp/2
> echo foo > /tmp/1
> sh: cannot write /tmp/1: Inalid argument

Probably you are right. When I have some time to build and boot 2.6.24
at last, I hope I'll find what this example is about...

> But whatever.   It used to work.  People's scripts will break.  Regression.

Do you mean people didn't have to change their scripts before, e.g.
from linux 2.0.? Scripts are kind of programs, and both APIs and some
'undocumented' features are achanging...

Regards,
Jarek P.

Regards,
Jarek P.
