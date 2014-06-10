From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next 3/4] bridge: Consider the Nearest
 Customer Bridge group addresses
Date: Tue, 10 Jun 2014 16:05:07 +0900
Message-ID: <5396AE23.80808@lab.ntt.co.jp>
References: <1402313687-28067-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>	
	<1402313687-28067-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>	
	<20140609085243.32f88582@nehalam.linuxnetplumber.net>
	<1402332351.1742.16.camel@localhost.localdomain>
	<5396363E.2020501@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	"David S . Miller" <davem@davemloft.net>
To: vyasevic@redhat.com, Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5396363E.2020501@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

(2014/06/10 7:33), Vlad Yasevich wrote:
...
>>> Rather than special casing this around vlan filtering, I would prefer
>>> the code always forward these packets, or manipulate group_fwd_mask
>>> to allow it that way.
>>
>> These addresses must be forwarded only if the bridge is an S-VLAN
>> bridge. When it is a C-VLAN bridge or a .1D bridge, they may not be
>> forwarded. So, I don't think we can forward them always.
>>
>> Using group_fwd_mask is a bit complicated. If we use it to forward them,
>> user can optionally turn off forwarding ability of those addresses...
>> but we maybe need another information (named like group_fwd_mask_set)
>> that indicates which bit is set by user. (We have to set group_fwd_mask
>> automatically when we set vlan_proto to 88a8.)
>> Is this way acceptable?
> 
> May be separate it into required mask and user mask.  Set required
> mask when this is an S-VLAN bridge.

Sounds like a good idea.
I'll give it a try, thank you for your suggestion.

Thanks,
Toshiaki Makita
