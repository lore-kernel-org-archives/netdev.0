From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: vlan: fix usage of vlan 0 and 4095
	again
Date: Thu, 02 Jul 2015 12:19:43 -0700 (PDT)
Message-ID: <20150702.121943.1748089320778953562.davem@davemloft.net>
References: <1435841297-44200-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com,
	bridge@lists.linux-foundation.org, roopa@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1435841297-44200-1-git-send-email-nikolay@cumulusnetworks.com>
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

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu,  2 Jul 2015 05:48:17 -0700

> Vlan ids 0 and 4095 were disallowed by commit:
> 8adff41c3d25 ("bridge: Don't use VID 0 and 4095 in vlan filtering")
> but then the check was removed when vlan ranges were introduced by:
> bdced7ef7838 ("bridge: support for multiple vlans and vlan ranges in setlink and dellink requests")
> So reintroduce the vlan range check.
> Before patch:
> [root@testvm ~]# bridge vlan add vid 0 dev eth0 master
> (succeeds)
> After Patch:
> [root@testvm ~]# bridge vlan add vid 0 dev eth0 master
> RTNETLINK answers: Invalid argument
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: bdced7ef7838 ("bridge: support for multiple vlans and vlan ranges in setlink and dellink requests")

Applied.
