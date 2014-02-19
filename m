From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hyperv: Add latest NetVSP versions to auto
 negotiation
Date: Wed, 19 Feb 2014 16:23:12 -0500 (EST)
Message-ID: <20140219.162312.1711517042878098859.davem@davemloft.net>
References: <1392755334-25884-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1392755334-25884-1-git-send-email-haiyangz@microsoft.com>
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
Date: Tue, 18 Feb 2014 12:28:54 -0800

> +	u32 ver_list[] = {NVSP_PROTOCOL_VERSION_1, NVSP_PROTOCOL_VERSION_2,
> +		NVSP_PROTOCOL_VERSION_4, NVSP_PROTOCOL_VERSION_5};

Please put a space after "{" and before "}".

> +	int i, num_ver = 4; /* number of different NVSP versions */
> +
>  
>  	net_device = get_outbound_net_device(device);

Please delete the extraneous empty line.

> +	for (i = num_ver - 1; i >= 0; i--)
> +		if (negotiate_nvsp_ver(device, net_device, init_packet,
> +			ver_list[i])  == 0) {

This is not indented properly, "ver_list[i])" should begin precisely after
the openning parenthesis of the negotiate_nvsp_ver() function call.
