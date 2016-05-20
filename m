From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable v2] net: cdc_ncm: update datagram size after
 changing mtu
Date: Fri, 20 May 2016 19:32:02 -0400 (EDT)
Message-ID: <20160520.193202.1451120008648712255.davem@davemloft.net>
References: <1463651769-27513-1-git-send-email-robert.dobrowolski@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, stable@vger.kernel.org,
	oliver@neukum.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rafal.f.redzimski@intel.com
To: robert.dobrowolski@linux.intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1463651769-27513-1-git-send-email-robert.dobrowolski@linux.intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Dobrowolski <robert.dobrowolski@linux.intel.com>
Date: Thu, 19 May 2016 11:56:09 +0200

> From: Rafal Redzimski <rafal.f.redzimski@intel.com>
> 
> Current implementation updates the mtu size and notify cdc_ncm
> device using USB_CDC_SET_MAX_DATAGRAM_SIZE request about datagram
> size change instead of changing rx_urb_size.
> 
> Whenever mtu is being changed, datagram size should also be
> updated. Also updating maxmtu formula so it takes max_datagram_size with
> use of cdc_ncm_max_dgram_size() and not ctx.
> 
> Signed-off-by: Robert Dobrowolski <robert.dobrowolski@linux.intel.com>
> Signed-off-by: Rafal Redzimski <rafal.f.redzimski@intel.com>

Appied, thanks.
