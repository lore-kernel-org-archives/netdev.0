From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: Submission for S2io 10GbE driver
Date: Mon, 26 Jan 2004 22:19:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000401c3e49d$922d8140$0400a8c0@S2IOtech.com>
References: <40160060.4010709@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Stephen Hemminger'" <shemminger@osdl.org>, "'Andi Kleen'" <ak@suse.de>,
        <netdev@oss.sgi.com>, <raghavendra.koushik@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <40160060.4010709@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> 
> The ethtool diag stuff is more of a quick sanity test than anything 
> exhaustive.
> 
> I definitely want to discourage tons of test code in drivers, as its 
> code that users will almost-never run, it bloats the driver, 
> and can be 
> done with a special diag-only driver or diag program (or a 
> combination 
> of both).
> 
> A lot of the 10/100 drivers originated from Donald Becker, 
> who typically 
> creates a userland (i.e. separate) diag program for each 
> driver he writes.


I see the point; we'll go ahead and get rid of the loopback.
We actually have pretty extensive standalone diag tool that is based on
diag driver.

Thanks, Leonid


> 
> 	Jeff
> 
> 
> 
