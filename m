From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 0/2] bridge: netlink: add missing policy
 entries and sizes
Date: Tue, 4 Aug 2015 16:54:14 -0700
Message-ID: <20150804165414.0332926d@urahara>
References: <1438707993-14561-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, kyeyoonp@codeaurora.org,
	jouni@codeaurora.org, davem@davemloft.net
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1438707993-14561-1-git-send-email-razor@blackwall.org>
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

On Tue,  4 Aug 2015 19:06:31 +0200
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Hi,
> When IFLA_BRPORT_PROXYARP and PROXYARP_WIFI were introduced they weren't
> accounted for in the get_slave_size() callback and didn't get a policy
> entry, so fix it now. Sending as two separate patches because the first
> one goes further back than the second and thus we get 2 different Fixes
> tags.
> 
> Cheers,
>  Nik
> 
> Nikolay Aleksandrov (2):
>   bridge: netlink: account for the IFLA_BRPORT_PROXYARP attribute size
>     and policy
>   bridge: netlink: account for the IFLA_BRPORT_PROXYARP_WIFI attribute
>     size and policy
> 
>  net/bridge/br_netlink.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
