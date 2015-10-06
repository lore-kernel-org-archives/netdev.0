From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/8] bridge: netlink: export port's
	root id
Date: Tue, 6 Oct 2015 14:43:01 +0200
Message-ID: <5613C1D5.80702@cumulusnetworks.com>
References: <201510062037.Kw9qnttB%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, kbuild-all@01.org, davem@davemloft.net
To: kbuild test robot <lkp@intel.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <201510062037.Kw9qnttB%fengguang.wu@intel.com>
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

On 10/06/2015 02:30 PM, kbuild test robot wrote:
> Hi Nikolay,
> 
> [auto build test ERROR on v4.3-rc4 -- if it's inappropriate base, please ignore]
> 
> config: x86_64-randconfig-x016-201540 (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    net/bridge/br_netlink.c: In function 'br_port_info_size':
>>> net/bridge/br_netlink.c:116:27: error: invalid application of 'sizeof' to incomplete type 'struct ifla_bridge_id'
>       + nla_total_size(sizeof(struct ifla_bridge_id)) /* IFLA_BRPORT_ROOT_ID */
>                               ^
>    net/bridge/br_netlink.c: In function 'br_port_fill_attrs':
>    net/bridge/br_netlink.c:151:47: error: invalid application of 'sizeof' to incomplete type 'struct ifla_bridge_id'
>          nla_put(skb, IFLA_BRPORT_ROOT_ID, sizeof(struct ifla_bridge_id),
>                                                   ^
>    net/bridge/br_netlink.c: In function 'br_port_info_size':
>>> net/bridge/br_netlink.c:118:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }
>     ^

This is incorrect, the structure is in net-next. My previous set introduced it:
commit 5127c81f84de ("bridge: netlink: export root id")

Cheers,
 Nik
