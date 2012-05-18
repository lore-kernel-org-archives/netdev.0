From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] xfrm: take iphdr size into account for esp payload
 size calculation
Date: Thu, 17 May 2012 20:05:09 -0400 (EDT)
Message-ID: <20120517.200509.2290282427866555176.davem@davemloft.net>
References: <20120514.183952.1459413342269893446.davem@davemloft.net>
	<1337196925-4919-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, steffen.klassert@secunet.com
To: bpoirier@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337196925-4919-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Poirier <bpoirier@suse.de>
Date: Wed, 16 May 2012 15:35:25 -0400

> Corrects the function that determines the esp payload size.
> The calculations done in esp4_get_mtu lead to overlength frames in transport
> mode for certain mtu values and suboptimal frames for others.
> 
> According to what is done, mainly in esp_output(), net_header_len aka
> sizeof(struct iphdr) must be taken into account before doing the alignment
> calculation.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

This looks great.

Could you please fix net/ipv6/esp6.c too, it seems to have the same
exact bug.

Once you respin this patch with both ipv4 and ipv6 fixed, I'll apply
it.

Thank you.
