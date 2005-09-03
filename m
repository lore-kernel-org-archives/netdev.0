From: Andrew Morton <akpm@osdl.org>
Subject: Re: Kernel 2.6.13 breaks libpcap (and tcpdump).
Date: Fri, 2 Sep 2005 17:27:19 -0700
Message-ID: <20050902172719.4eaaa6db.akpm@osdl.org>
References: <20050902184416.GA6468@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161097AbVICA12@vger.kernel.org>
To: John McGowan <jmcgowan@inch.com>
In-Reply-To: <20050902184416.GA6468@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John McGowan <jmcgowan@inch.com> wrote:
>
> Kernel 2.6.13. Breaks libpcap.
> 
> Fedora Core 2, gcc 3.3.3, Pentium III (933MHz)
> 
> I had written about my dismay that traceproto and tcptraceroute
> no longer worked and suspected that libnet was broken.
> 
> It seems that it is libpcap that is broken by kernel 2.6.13 and
> tcpdump itself no longer works.
> Well, it works ... but not correctly.
> 
>  Capture data, then look for ICMP messages
>  (e.g. Time Exceeded errors as in a traceroute)
>  by filtering the file.
>  
>   tcpdump -w 1.cap
>   tcpdump -f "ip proto \icmp" -r 1.cap
> 
> That works.
> 
> 
>  Filter incoming data, looking for ICMP messages:
>  
>   tcpdump -f "ip proto \icmp"
>  
> Well, that catches nothing.
> 
> 
> I tried recompiling (source RPM, Fedora Core 2) tcpdump
> (libpcap, tcpdump, etc.) and reinstalling. That did not
> fix the problem with tcpdump.
> 
> It also broke a tethereal script I was using (which I changed
> to capture all packets, which works as indicated above, and
> then used a '-R', read, filter to display the one's I want).
> 

(cc netdev)
