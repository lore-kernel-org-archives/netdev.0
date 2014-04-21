From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,1/2] hyperv: Remove recv_pkt_list and lock
Date: Mon, 21 Apr 2014 14:57:11 -0400 (EDT)
Message-ID: <20140421.145711.1903592201158395025.davem@davemloft.net>
References: <1398108376-4857-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1398108376-4857-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Mon, 21 Apr 2014 12:26:15 -0700

> @@ -401,8 +401,6 @@ static void rndis_filter_receive_data(struct rndis_device *dev,
>  	pkt->total_data_buflen = rndis_pkt->data_len;
>  	pkt->data = (void *)((unsigned long)pkt->data + data_offset);
>  
> -	pkt->is_data_pkt = true;
> -
>  	vlan = rndis_get_ppi(rndis_pkt, IEEE_8021Q_INFO);
>  	if (vlan) {
>  		pkt->vlan_tci = VLAN_TAG_PRESENT | vlan->vlanid |

This part of your change is not explained at all in your commit message.

Please resubmit this series with this hunk properly described and
accounted for.
