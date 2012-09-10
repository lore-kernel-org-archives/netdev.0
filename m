From: Guy Harris <guy@alum.mit.edu>
Subject: Re: Modular arithmetic
Date: Mon, 10 Sep 2012 10:50:30 -0700
Message-ID: <2B555EBC-A130-476B-9E29-DB75E668904E@alum.mit.edu>
References: <20120905213941.03c85968@arrowsmith>
	<C71A36A8-08D2-4D3D-AF2B-EF89FEECE1A6@alum.mit.edu>
	<20120906073615.693d14e0@arrowsmith>
	<46AB14E3-73F4-41FA-8086-F1D663AF4549@alum.mit.edu>
	<20120907074910.2df46817@arrowsmith>
	<20120908030311.GM17289@tassilo.jf.intel.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6FE4@saturn3.aculab.com>
	<1347269124.1234.1326.camel@edumazet-glaptop>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6FE5@saturn3.aculab.com>
Mime-Version: 1.0 (Mac OS X Mail 6.0 \(1486\))
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Schulist <jschlst@samba.org>,
	Andi Kleen <ak@linux.intel.com>, tcpdump-workers@lists.tcpdump.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <tcpdump-workers-bounces@lists.tcpdump.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FE5@saturn3.aculab.com>
List-Unsubscribe: <https://lists.sandelman.ca/mailman/options/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=unsubscribe>
List-Archive: <http://lists.sandelman.ca/pipermail/tcpdump-workers>
List-Post: <mailto:tcpdump-workers@lists.tcpdump.org>
List-Help: <mailto:tcpdump-workers-request@lists.tcpdump.org?subject=help>
List-Subscribe: <https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=subscribe>
Sender: tcpdump-workers-bounces@lists.tcpdump.org
Errors-To: tcpdump-workers-bounces@lists.tcpdump.org
List-Id: netdev.vger.kernel.org


On Sep 10, 2012, at 3:41 AM, "David Laight" <David.Laight@ACULAB.COM> wrote:

>>> What about the other OS - eg all the BSDs?
>>> I had a vague idea that BPF was supposed to be reasonable portable.
>> 
>> Yes, does it mean BPF is frozen ?
>> 
>> Or is BSD so hard to update these days ?
> 
> Not really - but it some other places that need updating in order
> to make this useful for cross-platform tools (like tcpdump).
> 
> The 'real fun (tm)' happens when NetBSD tries to run Linux binaries
> that include the Linux libpcap.

Additional fun happens when a Linux system with a kernel that doesn't have the mod instruction tries to run Linux binaries that include a Linux libpcap that generates code using the mod instruction; this is not a BSD-vs.-Linux issue, it's a "kernel that lacks the mod instruction vs. libpcap that generates code that includes the mod instruction" issue.

BSD/OS X, Linux, Solaris, and the WinPcap driver need, if they adopt new BPF instructions, to have a mechanism by which libpcap (or anything else using BPF filtering) can inquire about the capabilities of the OS BPF interpreter; libpcap would use that to determine what code to generate if generating code for the in-kernel BPF interpreter.

(Please reply to tcpdump-workers@lists.tcpdump.org as well as to netdev@vger.kernel.org, so that people not on both of those lists can follow the discussion.  Messages from non-members of tcpdump-workers to tcpdump-workers shouldn't bounce, but they do need to be approved by a moderator; Michael, if you want to at least temporarily turn the flood on for my e-mail address, so I can help moderate, go ahead.)
_______________________________________________
tcpdump-workers mailing list
tcpdump-workers@lists.tcpdump.org
https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers
