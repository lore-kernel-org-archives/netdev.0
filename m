From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Submission for S2io 10GbE driver
Date: Tue, 27 Jan 2004 01:08:32 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40160060.4010709@pobox.com>
References: <001801c3e497$010671a0$0400a8c0@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Stephen Hemminger'" <shemminger@osdl.org>, "'Andi Kleen'" <ak@suse.de>,
        netdev@oss.sgi.com, raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <001801c3e497$010671a0$0400a8c0@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Leonid Grossman wrote:
> The loopback test is there as a part of the ethtool's diagnostic option.
> 
> 
> There are pros and cons of having the test in there I guess, anyone else
> has an opinion on this?
> 
> Do other net drivers normally support loopback and other diag tests as a
> part of the ethtool support,
> or they provide little/no support for the option and ship a standalone
> diag program instead?


The ethtool diag stuff is more of a quick sanity test than anything 
exhaustive.

I definitely want to discourage tons of test code in drivers, as its 
code that users will almost-never run, it bloats the driver, and can be 
done with a special diag-only driver or diag program (or a combination 
of both).

A lot of the 10/100 drivers originated from Donald Becker, who typically 
creates a userland (i.e. separate) diag program for each driver he writes.

	Jeff
