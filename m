From: supersud501 <supersud501@yahoo.de>
Subject: Re: [Bugme-new] [Bug 9721] New: wake on lan fails with sky2 module
Date: Sun, 13 Jan 2008 14:22:11 +0100
Message-ID: <478A1083.5060406@yahoo.de>
References: <bug-9721-10286@http.bugzilla.kernel.org/> <200801112216.08992.rjw@sisk.pl> <4787EB69.9060900@yahoo.de> <200801120010.22440.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp002.mail.ukl.yahoo.com ([217.12.11.33]:26302 "HELO
	smtp002.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750720AbYAMNWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 08:22:15 -0500
In-Reply-To: <200801120010.22440.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Rafael J. Wysocki wrote:

> 
> Since it seems to be 100% reproducible, it would be very helpful if you could
> use git-bisect to identify the offending commit.
> 

allright, bisect found the offending commit, here's what i've done:

first i started bisect with the following command (since i assumed it is 
a net-driver problem):

git-bisect start 'v2.6.24-rc6' 'v2.6.23' '--' 'drivers/net/'

after building many kernels and saying good/bad if wol worked/didn't 
work etc. it identified the following commit:

# bad: [ac93a3946b676025fa55356180e8321639744b31] sky2: enable PCI 
config writes

and refs/bisect/bad gives:

14:16:53 /usr/src/linux-2.6/.git # cat refs/bisect/bad
ac93a3946b676025fa55356180e8321639744b31


need some more info?
