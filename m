From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH v10 net-next 4/6] tcp: add low latency
	socket poll support.
Date: Mon, 10 Jun 2013 12:38:35 -0400
Message-ID: <CA+FuTScdGoeocndgGM9=rE+1BAa3urxHWXSpimJ7o7726NhF9g@mail.gmail.com>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
	<20130610084010.6955.14413.stgit@ladj378.jer.intel.com>
	<1370874744.3252.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, HPA <hpa@zytor.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1370874744.3252.5.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Jun 10, 2013 at 10:32 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-06-10 at 11:40 +0300, Eliezer Tamir wrote:
>> Adds low latency socket poll support for TCP.
>> In tcp_v[46]_rcv() add a call to sk_mark_ll() to copy the napi_id
>> from the skb to the sk.
>> In tcp_recvmsg(), when there is no data in the socket we busy-poll.
>> This is a good example of how to add busy-poll support to more protocols.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> ---
>
> Acked-by: Eric Dumazet <edumazet@google.com>
>

Tested-by: Willem de Bruijn <willemb@google.com>

(per Eliezer's request)

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
