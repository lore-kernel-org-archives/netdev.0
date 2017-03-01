From: Roopa Prabhu via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH net] bridge: Fix error path in nbp_vlan_init
Date: Wed, 01 Mar 2017 10:25:36 -0800
Message-ID: <58B71220.6080306@cumulusnetworks.com>
References: <1488379845-38625-1-git-send-email-yotamg@mellanox.com>
Reply-To: Roopa Prabhu <roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: idosch@mellanox.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, jiri@mellanox.com,
	eladr@mellanox.com, davem@davemloft.net
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1488379845-38625-1-git-send-email-yotamg@mellanox.com>
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

On 3/1/17, 6:50 AM, Yotam Gigi wrote:
> Fix error path order in nbp_vlan_init, so if switchdev_port_attr_set
> call failes, the vlan_hash wouldn't be destroyed before inited.
>
> Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> ---
>  
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks yotam.
