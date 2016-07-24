From: Lukas Wunner <lukas@wunner.de>
Subject: Re: [PATCH v4 5/7] thunderbolt: Networking state machine
Date: Mon, 25 Jul 2016 00:36:35 +0200
Message-ID: <20160724223635.GA9516@wunner.de>
References: <1468836040-28043-1-git-send-email-amir.jer.levy@intel.com>
 <1468836040-28043-6-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	thunderbolt-linux@intel.com, mika.westerberg@intel.com,
	tomas.winkler@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1468836040-28043-6-git-send-email-amir.jer.levy@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 01:00:38PM +0300, Amir Levy wrote:
> +	const unique_id_be proto_uuid = APPLE_THUNDERBOLT_IP_PROTOCOL_UUID;
> +
> +	if (memcmp(proto_uuid, hdr->apple_tbt_ip_proto_uuid,
> +		   sizeof(proto_uuid)) != 0) {

You may want to use the uuid_be data type provided by <linux/uuid.h>
instead of rolling your own, as well as the helper uuid_be_cmp()
defined ibidem.

Thanks,

Lukas
