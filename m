From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 4/11]  use ether_addr_equal_64bits
Date: Mon, 30 Dec 2013 20:58:55 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1312302057420.2209@localhost6.localdomain6>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>  <1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>  (sfid-20131230_182319_112673_F481A1D3) <1388429761.4410.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	kernel-janitors@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388429761.4410.1.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Seems to be missing an "iwlwifi:" or so prefix, but I guess we can add
> it when we take the patch ...

Sorry.  Not sure why that happened.  I'll look into it.

> Is there any way we could catch (sparse, or some other script?) that
> struct reorganising won't break the condition needed ("within a
> structure that contains at least two more bytes")?

What kind of reorganizing could happen?  Do you mean that the programmer 
might do at some time in the future, or something the compiler might do?

julia
