From: Terje Eggestad <terje.eggestad@scali.com>
Subject: Re: anyone ever done multicast AF_UNIX sockets?
Date: 03 Mar 2003 20:42:12 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1046720532.28127.213.camel@eggis1>
References: <3E6399F1.10303@nortelnetworks.com>
	<20030303.095641.87696857.davem@redhat.com>
	<3E63A8CB.2090307@nortelnetworks.com>
	<20030303.105646.02089773.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: cfriesen@nortelnetworks.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030303.105646.02089773.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-03-03 at 19:56, David S. Miller wrote:
       From: Chris Friesen <cfriesen@nortelnetworks.com>
       Date: Mon, 03 Mar 2003 14:11:07 -0500
       
       I haven't done UDP bandwidth testing--I need to check how lmbench
       did it for the unix socket and do the same for UDP.  Local TCP was
       far slower than unix sockets though.
    
    That result is system specific and depends upon how the data and
    datastructures hit the cpu cachelines in the kernel.
    
    TCP bandwidth is slightly faster than AF_UNIX bandwidth on my
    sparc64 boxes for example.

I've seen that their are the same on linux.I tried to to do AF_UNIX
instead of AF_INET internally to boost perf, but to no avail. Makes you
suspect that the loopback device actually create an AF_UNIX connection
under the hood ;-)


-- 
_________________________________________________________________________

Terje Eggestad                  mailto:terje.eggestad@scali.no
Scali Scalable Linux Systems    http://www.scali.com

Olaf Helsets Vei 6              tel:    +47 22 62 89 61 (OFFICE)
P.O.Box 150, Oppsal                     +47 975 31 574  (MOBILE)
N-0619 Oslo                     fax:    +47 22 62 89 51
NORWAY            
_________________________________________________________________________
