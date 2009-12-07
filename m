From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14730] New: sky2 won't work after
 suspend/resume cycle
Date: Mon, 7 Dec 2009 11:50:57 -0800
Message-ID: <20091207115057.424774d3.akpm@linux-foundation.org>
References: <bug-14730-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, mat@esi.com.pl
To: netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <bug-14730-10286@http.bugzilla.kernel.org/>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 4 Dec 2009 09:02:21 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14730
> 
>            Summary: sky2 won't work after suspend/resume cycle
>            Product: Power Management
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Hibernation/Suspend
>         AssignedTo: power-management_other@kernel-bugs.osdl.org
>         ReportedBy: mat@esi.com.pl
>         Regression: Yes
> 
> 
> I use sky2 network adapter in my Fujitsu Siemens Esprimo Mobile U9200. It
> worked fine up until 2.6.31-rc3 (or at least that's the last one I tried it
> works for me) and in all versions after that I tried it stops working after
> suspend/resume cycle (I use powersave daemon, but I also tried without it -
> effect is the same). 
> 
> After resume what I see in dmesg is this:
> 
> sky2 driver version 1.23
> sky2 0000:04:00.0: enabling device (0000 -> 0003)
> sky2 0000:04:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
> sky2 0000:04:00.0: setting latency timer to 64
> sky2 0000:04:00.0: unsupported chip type 0xff

It looks like reads from the device are returning all-ones.  

> sky2 0000:04:00.0: PCI INT A disabled
> sky2: probe of 0000:04:00.0 failed with error -95
> 
> So it looks like something is probably not restored correctly after resume or
> some initializations are not executed.
> 
> I use Gentoo sources, but I also tried it on vanilla kernels - 2.6.31 and
> 2.6.32-rc8 and it doesn't work in any version past 2.6.31-rc3.
> 

Help.  Do we think this regression is likely to be a sky2 thing, an
ACPI thing, an x86 arch thing or...?

Thanks.
