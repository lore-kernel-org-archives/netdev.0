From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] Drivers: net: hyperv: Enable large send offload
Date: Thu, 06 Mar 2014 14:34:54 -0500 (EST)
Message-ID: <20140306.143454.1047620719955721469.davem@davemloft.net>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-6-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394104390-23477-6-git-send-email-kys@microsoft.com>
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

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Thu,  6 Mar 2014 03:13:10 -0800

> +	ppi = init_ppi_data(rndis_msg, NDIS_LSO_PPI_SIZE,
> +				TCP_LARGESEND_PKTINFO);

This is not indented properly, "TCP_LARGESEND_PKTINFO);" should start at the
first column after the openning parenthesis of "init_ppi_data(".

> +		~csum_tcpudp_magic(ip_hdr(skb)->saddr,
> +				ip_hdr(skb)->daddr, 0, IPPROTO_TCP, 0);

Likewise.
