From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCHv3 net-next 1/6] bridge: simplify the
 flush_store by calling store_bridge_parm
Date: Sat, 9 Apr 2016 14:27:32 +0200
Message-ID: <5708F534.4000308@cumulusnetworks.com>
References: <cover.1460131308.git.lucien.xin@gmail.com>
	<6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1460131308.git.lucien.xin@gmail.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>, network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1460131308.git.lucien.xin@gmail.com>
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

On 04/08/2016 06:03 PM, Xin Long wrote:
> There are some repetitive codes in flush_store, we can remove
> them by calling store_bridge_parm, also, it would send rtnl notification
> after we add it in store_bridge_parm in the following patches.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/bridge/br_sysfs_br.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
