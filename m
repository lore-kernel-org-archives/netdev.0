From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/11]  use ether_addr_equal_64bits
Date: Mon, 30 Dec 2013 19:56:01 +0100
Message-ID: <1388429761.4410.1.camel@jlt4.sipsolutions.net>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
	 <1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>
	 (sfid-20131230_182319_112673_F481A1D3)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr> (sfid-20131230_182319_112673_F481A1D3)
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-12-30 at 19:15 +0100, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
> used when each argument is an array within a structure that contains at
> least two bytes of data beyond the array.
> 
> The structures involved are:
> iwl_rxon_cmd defined in drivers/net/wireless/iwlwifi/dvm/commands.h and
> ieee80211_hdr defined in include/linux/ieee80211.h
> 
> This was done using Coccinelle (http://coccinelle.lip6.fr/).

Seems to be missing an "iwlwifi:" or so prefix, but I guess we can add
it when we take the patch ...

Is there any way we could catch (sparse, or some other script?) that
struct reorganising won't break the condition needed ("within a
structure that contains at least two more bytes")?

johannes

