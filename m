From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 1/3] NetXen: Fixed /sys mapping between device and driver
Date: Tue, 7 Nov 2006 17:49:10 +0100
Message-ID: <200611071749.11359.netdev@axxeo.de>
References: <Pine.LNX.4.64.0611070818320.26206@dut39> <Pine.LNX.4.64.0611070835060.26206@dut39>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, wendyx@us.ibm.com,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:13220 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S964855AbWKGQtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 11:49:24 -0500
To: "Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <Pine.LNX.4.64.0611070835060.26206@dut39>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Amit,

one minor nitpick:

You wrote:
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index b54ea16..4effb87 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
[...]
> @@ -1040,7 +1041,7 @@ static int netxen_nic_poll(struct net_de
>   		netxen_nic_enable_int(adapter);
>   	}
> 
> -	return (done ? 0 : 1);
> +	return (!done);
	return !done;

Please lose the braces here (CodingStyle).

Just respin or send this change along with later patchsets.

Regards

Ingo Oeser
