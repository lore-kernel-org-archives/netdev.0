From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: tunnel: fix attribute checks
 in br_parse_vlan_tunnel_info
Date: Tue, 07 Feb 2017 14:05:47 -0500 (EST)
Message-ID: <20170207.140547.2299505726498784722.davem@davemloft.net>
References: <c341a60f-f3d1-29f6-b825-5ebd1432e5b9@cumulusnetworks.com>
	<1486468006-8080-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, colin.king@canonical.com
To: nikolay@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1486468006-8080-1-git-send-email-nikolay@cumulusnetworks.com>
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
Date: Tue,  7 Feb 2017 12:46:46 +0100

> These checks should go after the attributes have been parsed otherwise
> we're using tb uninitialized.
> 
> Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
> Reported-by: Colin Ian King <colin.king@canonical.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
