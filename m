From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: kerneloops.org report for the week of October 31 2009
Date: Sun, 1 Nov 2009 00:20:20 +0100
Message-ID: <200911010020.20284.rjw@sisk.pl>
References: <20091031160351.26fcc6c5@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	linux-acpi@vger.kernel.org, tytso@mit.edu, netdev@vger.kernel.org,
	Eric Paris <eparis@redhat.com>, akpm@linux-foundation.org,
	Matt Domsch <Matt_Domsch@dell.com>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20091031160351.26fcc6c5@infradead.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 01 November 2009, Arjan van de Ven wrote:
> 
> This week, a total of 18023 oopses and warnings have been reported,
> compared to 5816 reports in the previous week. This number and this
> report only includes kernel 2.6.31 and later.
> 
> This week, the Ubuntu 9.10 distribution got released, which includes
> kerneloops.org integration in the quality feedback system. I'd like
> to thank the Ubuntu team for their effort in helping to get the quality
> feedback about the kernel integrated into kerneloops.org.
> 
> 
> One thing to note is that the Ubuntu 9.10 release ships with the kernel
> debug option CONFIG_PM_TEST_SUSPEND enabled, causing many warnings to 
> be submitted. This huge volume triggered me to split these reports, as well
> as the check_bios_for_corruption() reports into a per machine entry.
> 
> The top 5 machines for which the suspend test fails:
>    319 | suspend_test_finish(Latitude D830)
>    231 | suspend_test_finish(XPS M1530)
>    225 | suspend_test_finish(MacBook2,1)
>    171 | suspend_test_finish(Compaq Presario CQ60 Notebook PC)
>    157 | suspend_test_finish(Studio XPS 1340)
> 
> and there is also the very elegant 
>    267 | suspend_test_finish(To Be Filled By O.E.M)
> 
> 
> The top 5 machines where the BIOS corrupts memory:
>     80 | check_for_bios_corruption(HP Compaq nx6110)
>     69 | check_for_bios_corruption(HP Compaq nc6120)
>     62 | check_for_bios_corruption(HP Pavilion dv6700 Notebook PC)
>     49 | check_for_bios_corruption(HP Pavilion dv2700 Notebook PC)
>     32 | check_for_bios_corruption(Compaq Presario F700 Notebook PC)
> 
> 
> The report this week looks different from previous reports; the version
> cut-off has moved to 2.6.31 so that a lot of older bugs now dropped out of the report.
> 
> New this week are some inotify bugs, that have been fixed in Linus' git tree after -rc5.
> There's also an ext2 warning for when the user unplugs a USB stick, as well as the
> usual binary and external kernel modules.
> 
> If you have (better) descriptions for some of these, let me know and I can add them to the
> database.
> 
> 
> 
> 
> Rank 1: suspend_test_finish(System Product Name) (warning)
> 	Reported 930 times (1510 total reports)
> 	This warning was last seen in version 2.6.31, and first seen in 2.6.27.15.
> 	More info: http://www.kerneloops.org/searchweek.php?search=suspend_test_finish(System Product Name)

This should be fixed by commit 04bf7539c08d64184736cdc5e4ad617eda77eb0f
(PM: Make warning in suspend_test_finish() less likely to happen), at least on some
machines that report it.

Thanks,
Rafael
