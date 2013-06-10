From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH v10 net-next 3/6] udp: add low latency
	socket poll support
Date: Mon, 10 Jun 2013 12:38:20 -0400
Message-ID: <CA+FuTSc1tcDDuqDiKJ=gSj7htX63EVa_kzK4O5UKtZWA87+dew@mail.gmail.com>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
	<20130610084000.6955.20487.stgit@ladj378.jer.intel.com>
	<1370874668.3252.4.camel@edumazet-glaptop>
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
In-Reply-To: <1370874668.3252.4.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Jun 10, 2013 at 10:31 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-06-10 at 11:40 +0300, Eliezer Tamir wrote:
>> Add upport for busy-polling on UDP sockets.
>> In __udp[46]_lib_rcv add a call to sk_mark_ll() to copy the napi_id
>> from the skb into the sk.
>> This is done at the earliest possible moment, right after we identify
>> which socket this skb is for.
>> In __skb_recv_datagram When there is no data and the user
>> tries to read we busy poll.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> ---
>>
>>  net/core/datagram.c |    4 ++++
>>  net/ipv4/udp.c      |    6 +++++-
>>  net/ipv6/udp.c      |    6 +++++-
>>  3 files changed, 14 insertions(+), 2 deletions(-)
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
