From: Nguyen Dinh Nam <64vn@cardvn.net>
Subject: Re: Fw: [Bugme-new] [Bug 4177] New: Please consider adding possibility
 to have multiple PPPoE sessions with different MAC addresses
Date: Mon, 07 Feb 2005 03:39:38 +0700
Message-ID: <4206808A.1050304@cardvn.net>
References: <20050206122604.74a41796.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
In-Reply-To: <20050206122604.74a41796.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have another situation - there are 2 different PPPoE access 
concentrators available on 1 interface. So I want to be able to specify 
the MAC address (or AC Name, or Service Name) of the AC to connect to
Thanks

Andrew Morton wrote:

>Begin forwarded message:
>
>Date: Sun, 6 Feb 2005 04:08:01 -0800
>From: bugme-daemon@osdl.org
>To: bugme-new@lists.osdl.org
>Subject: [Bugme-new] [Bug 4177] New: Please consider adding possibility to have multiple PPPoE sessions with different MAC addresses
>
>
>http://bugme.osdl.org/show_bug.cgi?id=4177
>
>           Summary: Please consider adding possibility to have multiple
>                    PPPoE sessions with different MAC addresses
>    Kernel Version: 2.6.current, 2.4.current
>            Status: NEW
>          Severity: low
>             Owner: acme@conectiva.com.br
>         Submitter: mh+kernel-bugzilla@zugschlus.de
>
>
>This wishlist item is mostly relevant to German users. In 
>Germany, Deutsche Telekom has a near monopoly regarding DSL 
>connections to residential homes. They are, however, required, to 
>resell their network to other ISPs which has led to a rather 
>interesting combination of Internet tariffs and feature sets available 
>via Deutsche Telekom T-DSL connections. 
> 
>Technical Basis for the T-DSL customer interface is PPPoE over a 
>bridged ATM session, so it is technically possible to have multiple 
>PPPoE sessions on the same line, allowing concurrent use of more than 
>a single ISP which might be interesting with special interest services 
>like streaming, fixed IP address and/or flat rate. 
> 
>However, Deutsche Telekom technically forbids multiple PPPoE sessions 
>originating from a single MAC address, so one needs multiple network 
>interfaces to originate the PPPoE sessions from. 
> 
>Sven Geggus has a patch against rp-pppoed, which allows to fake the 
>sending MAC address for additional PPPoE sessions, circumventing the 
>artificially introduced limitation of the T-DSL connection. The patch 
>is available on http://geggus.net/sven/rp-pppoe-fakemac.diff 
> 
>Please consider adding that possibility to the kernel PPPoE code as well. 
> 
>Greetings 
>Marc
>
>------- You are receiving this mail because: -------
>You are on the CC list for the bug, or are watching someone who is.
>
>
>  
>
