From: Andi Kleen <ak@suse.de>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Tue, 3 Feb 2004 09:14:11 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040203091411.19d3a676.ak@suse.de>
References: <Pine.LNX.4.58.0402021319440.5347@sorbus2.navaho>
	<Pine.LNX.4.33.0402021443570.6508-100000@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: steve@navaho.co.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
In-Reply-To: <Pine.LNX.4.33.0402021443570.6508-100000@blackhole.kfki.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004 14:46:24 +0100 (CET)
Jozsef Kadlecsik <kadlec@blackhole.kfki.hu> wrote:

> 
> You convinced me: something is really fishy. I fire up debugging and
> checking.

I also have some problems with conntrack since updating to 2.6.2rc3
from 2.6.1 on x86-64. Some TCP connections for the masqueraded machines 
seem to go extremly slow. I haven't investigated more closely yet.

/proc/slabinfo doesn't show leaks for the conntrack slab though.

-Andi
