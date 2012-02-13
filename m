From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 2/2] bluetooth: Convert BT_DBG to pr_debug
Date: Mon, 13 Feb 2012 07:37:37 +0100
Message-ID: <1329115057.28848.52.camel@aeonflux>
References: <cover.1329102581.git.joe@perches.com>
	 <90fbd8a0b800c83f5ad1df7889dc9b11d7d9c588.1329102581.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <90fbd8a0b800c83f5ad1df7889dc9b11d7d9c588.1329102581.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

> No need to obfuscate, just use the normal debugging macro.
> 
> Add "\n" to uses, align arguments, coalesce formats.
> Fix a typo and fix a bad format extended by a line continuation.

what is this patch buying us. Nothing at all. I rather not do this and
leave BT_DBG in it.

The only useful change would be to move to dev_printk, but we are not
there yet.

Regards

Marcel
