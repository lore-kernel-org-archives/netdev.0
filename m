From: supersud501 <supersud501@yahoo.de>
Subject: Re: [Bugme-new] [Bug 9721] New: wake on lan fails with sky2 module
Date: Sat, 12 Jan 2008 13:24:49 +0100
Message-ID: <4788B191.1060001@yahoo.de>
References: <bug-9721-10286@http.bugzilla.kernel.org/> <200801112216.08992.rjw@sisk.pl> <4787EB69.9060900@yahoo.de> <200801120010.22440.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <200801120010.22440.rjw@sisk.pl>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Rafael J. Wysocki wrote:
> On Friday, 11 of January 2008, supersud501 wrote:
>> Rafael J. Wysocki wrote:
>>>> http://bugzilla.kernel.org/show_bug.cgi?id=9721
> 
>> allright, didn't see that before, sorry, here are the results:
>>
>> kernel 2.6.23.12 acpi=off: when shutting down the system doesn't 
>> poweroff (of course), but pressing the powerbutton does the trick. and 
>> wake on lan: WORKS
>>
>> kernel 2.6.24-rc7 acpi=off: computer doesn't power off, either (so 
>> acpi=off works), but wol still DOESN'T work :(
>>
>> so no acpi-problem?
> 
> No, I don't think it's an ACPI problem.
> 
> Since it seems to be 100% reproducible, it would be very helpful if you could
> use git-bisect to identify the offending commit.
> 

I'll do the git-bisect (just downloading linux-2.6.git), but i forgot to 
mention one little thing: i'm using x64 version of kernel - does this 
play an important role?
