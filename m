From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net] bridge: vlan: fix usage of vlan 0 and 4095
	again
Date: Fri, 03 Jul 2015 00:46:23 +0900
Message-ID: <55955CCF.4020106@gmail.com>
References: <1435841297-44200-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
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

On 15/07/02 (木) 21:48, Nikolay Aleksandrov wrote:
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

Thank you for fixing this.

Acked-by: Toshiaki Makita <toshiaki.makita1@gmail.com>
