From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v2 net-next 3/3] net: add socket option
 for low latency polling
Date: Wed, 12 Jun 2013 15:54:59 +0300
Message-ID: <51B86FA3.1030306@linux.intel.com>
References: <20130612111942.19288.12131.stgit@ladj378.jer.intel.com>
	<20130612112016.19288.86849.stgit@ladj378.jer.intel.com>
	<1371041065.3252.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>,
	Avner Ben Hanoch <avnerb@mellanox.com>, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1371041065.3252.59.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/06/2013 15:44, Eric Dumazet wrote:
> On Wed, 2013-06-12 at 14:20 +0300, Eliezer Tamir wrote:
>> adds a socket option for low latency polling.
>> This allows overriding the global sysctl value with a per-socket one.
>>
>> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> ---
>
> It seems EXPORT_SYMBOL_GPL(sysctl_net_ll_poll) can now be removed ?

I think we would need it for poll.

Poll needs a way that is not dependent on any individual socket to know
how long to busy-wait, since we have to know it before we poll any
individual socket.

The patch I have right now for poll is not ready (and not fully tested).
But I can post it as an RFC if you want.

-Eliezer

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
