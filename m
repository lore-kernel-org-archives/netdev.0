From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH v10 net-next 1/6] net: add napi_id and hash
Date: Mon, 10 Jun 2013 12:38:00 -0400
Message-ID: <CA+FuTSchLFTiseMGAVJpBpYyE=8PmDb0huN_YvecfRUiBKHb=g@mail.gmail.com>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
	<20130610083940.6955.67403.stgit@ladj378.jer.intel.com>
	<1370856152.3252.2.camel@edumazet-glaptop>
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
In-Reply-To: <1370856152.3252.2.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Jun 10, 2013 at 5:22 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-06-10 at 11:39 +0300, Eliezer Tamir wrote:
>> Adds a napi_id and a hashing mechanism to lookup a napi by id.
>> This will be used by subsequent patches to implement low latency
>> Ethernet device polling.
>> Based on a code sample by Eric Dumazet.
>>
>> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> ---
>>
>>  include/linux/netdevice.h |   29 ++++++++++++++++++++++
>>  net/core/dev.c            |   59 +++++++++++++++++++++++++++++++++++++++++++++
>>  2 files changed, 88 insertions(+), 0 deletions(-)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
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
