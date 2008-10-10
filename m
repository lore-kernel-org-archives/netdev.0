From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH RFC]: e1000: allow VLAN devices to use TSO
	and CSUM offload
Date: Fri, 10 Oct 2008 15:01:09 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52066726B7@orsmsx418.amr.corp.intel.com>
References: <48EF690F.5070105@trash.net><36D9DB17C6DE9E40B059440DB8D95F520667243B@orsmsx418.amr.corp.intel.com><1223661576.3984.114.camel@achroite>
	<20081010.120905.132001378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org, "Waskiewicz Jr,
	Peter P" <peter.p.waskiewicz.jr@intel.com>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>, kaber@trash.net
To: "David Miller" <davem@davemloft.net>,
	<bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <20081010.120905.132001378.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David Miller wrote:
>> vlan_features is a mask for features.  So long as all parts that do
>> support TSO-IPv6 also support it for VLAN-tagged packets, it should
>> be safe to set NETIF_F_TSO6 in vlan_features unconditionally.
> 
> Right, it's an additional mask which gets and'd with the normal
> device feature bits.
> 
> Jesse, any objections, given that?

No, once that is explained I think it gets rid of any objections.  We
are going to test the patch now, so would you mind if you waited to take
it until jkirsher pushes it to you?

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
