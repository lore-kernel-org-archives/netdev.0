From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] NET: wimax, fix use after free
Date: Mon, 11 Oct 2010 11:12:18 -0700 (PDT)
Message-ID: <20101011.111218.112596606.davem@davemloft.net>
References: <1286789218-13976-1-git-send-email-jslaby@suse.cz>
	<1286789218-13976-3-git-send-email-jslaby@suse.cz>
	<1286815606.21592.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jslaby@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	linux-wimax@intel.com
To: inaky.perez-gonzalez@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286815606.21592.11.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Date: Mon, 11 Oct 2010 09:46:46 -0700

> On Mon, 2010-10-11 at 02:26 -0700, Jiri Slaby wrote: 
>> Stanse found that i2400m_rx frees skb, but still uses skb->len even
>> though it has skb_len defined. So use skb_len properly in the code.
>> 
>> And also define it unsinged int rather than size_t to solve
>> compilation warnings.
>> 
>> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> 
> Ops, fail. Thanks for the catch. I assume you have compile tested it.
> 
> Acked-by: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>

Applied.
