From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Bugme-new] [Bug 9721] New: wake on lan fails with sky2 module
Date: Sat, 12 Jan 2008 00:10:21 +0100
Message-ID: <200801120010.22440.rjw@sisk.pl>
References: <bug-9721-10286@http.bugzilla.kernel.org/> <200801112216.08992.rjw@sisk.pl> <4787EB69.9060900@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: supersud501 <supersud501@yahoo.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <4787EB69.9060900@yahoo.de>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, 11 of January 2008, supersud501 wrote:
> 
> Rafael J. Wysocki wrote:
> >> http://bugzilla.kernel.org/show_bug.cgi?id=9721

> allright, didn't see that before, sorry, here are the results:
> 
> kernel 2.6.23.12 acpi=off: when shutting down the system doesn't 
> poweroff (of course), but pressing the powerbutton does the trick. and 
> wake on lan: WORKS
> 
> kernel 2.6.24-rc7 acpi=off: computer doesn't power off, either (so 
> acpi=off works), but wol still DOESN'T work :(
> 
> so no acpi-problem?

No, I don't think it's an ACPI problem.

Since it seems to be 100% reproducible, it would be very helpful if you could
use git-bisect to identify the offending commit.
