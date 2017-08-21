From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ibm: emac: Fix some error handling path in
 'emac_probe()'
Date: Sun, 20 Aug 2017 19:53:20 -0700 (PDT)
Message-ID: <20170820.195320.1737734418974269546.davem@davemloft.net>
References: <20170820043500.24864-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chunkeey@googlemail.com, jarod@redhat.com, ivan@de.ibm.com,
        ebiggers@google.com, tklauser@distanz.ch, tremyfr@gmail.com,
        robh@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170820043500.24864-1-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sun, 20 Aug 2017 06:35:00 +0200

> If 'irq_of_parse_and_map()' or 'of_address_to_resource()' fail, 'err' is
> known to be 0 at this point.
> So return -ENODEV instead in the first case and use 'of_iomap()' instead of
> the equivalent 'of_address_to_resource()/ioremap()' combinaison in the 2nd
> case.
> 
> Doing so, the 'rsrc_regs' field of the 'emac_instance struct' becomes
> redundant and is removed.
> 
> While at it, turn a 'err != 0' test into an equivalent 'err' to be more
> consistent.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
> v2: use of_iomap() to simplify code
>     remove 'rsrc_regs' field of the 'emac_instance struct'
>     update comment

Applied to net-next.
