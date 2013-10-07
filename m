From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] eisa: standardize on eisa_register_driver like similar
 bus registrations
Date: Mon, 07 Oct 2013 16:02:25 -0400 (EDT)
Message-ID: <20131007.160225.1679994399484815968.davem@davemloft.net>
References: <1381026958-4459-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: tedheadster@gmail.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1381026958-4459-1-git-send-email-tedheadster@gmail.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthew Whitehead <tedheadster@gmail.com>
Date: Sat,  5 Oct 2013 22:35:58 -0400

> The other buses (isa, pci, pnp, parport, usb, tty, etc) all use the convention
> of ${BUSNAME}_register_driver. Rewrite the little remaining code that uses EISA
> to follow this convention for easier readability.
> 
> This affects the EISA bus, SCSI, and networking subsystems so only one should
> ultimately merge the patch if it is accepted.
> 
> Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>

I'm fine with someone else taking this, for networking parts:

Acked-by: David S. Miller <davem@davemloft.net>
