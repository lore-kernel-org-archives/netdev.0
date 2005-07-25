From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netlink connector
Date: Mon, 25 Jul 2005 16:32:32 +0200
Message-ID: <42E4F800.1010908@trash.net>
References: <20050723125427.GA11177@rama> <20050723091455.GA12015@2ka.mipt.ru>
	<20050724.191756.105797967.davem@davemloft.net>
	<Lynx.SEL.4.62.0507250154000.21934@thoron.boston.redhat.com>
	<20050725070603.GA28023@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Harald Welte <laforge@netfilter.org>,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, netdev@redhat.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20050725070603.GA28023@2ka.mipt.ru>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Mon, Jul 25, 2005 at 02:02:10AM -0400, James Morris (jmorris@redhat.com) wrote:
> 
>>On Sun, 24 Jul 2005, David S. Miller wrote:
>>
>>>From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
>>>Date: Sat, 23 Jul 2005 13:14:55 +0400
>>>
>>>
>>>>Andrew has no objection against connector and it lives in -mm
>>>
>>>A patch sitting in -mm has zero significance.
> 
> That is why I'm asking netdev@ people again...

If I understand correctly it tries to workaround some netlink
limitations (limited number of netlink families and multicast groups)
by sending everything to userspace and demultiplexing it there.
Same in the other direction, an additional layer on top of netlink
does basically the same thing netlink already does. This looks like
a step in the wrong direction to me, netlink should instead be fixed
to support what is needed.
