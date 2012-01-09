From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH] brcm80211: Don't leak 'vbuffer' in
 brcmf_sdbrcm_write_vars()
Date: Mon, 9 Jan 2012 11:01:15 +0100
Message-ID: <4F0ABAEB.5070306@broadcom.com>
References: <alpine.LNX.2.00.1201082338350.24030@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Alwin Beukers" <alwin@broadcom.com>,
	"Pieter-Paul Giesberts" <pieterpg@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: "Jesper Juhl" <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1201082338350.24030@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/08/2012 11:41 PM, Jesper Juhl wrote:
> If the memory allocation 'nvram_ularray = kmalloc(varsize,
> GFP_ATOMIC);' fails we'll leak the memory allocated to 'vbuffer' when
> we return -ENOMEM from the function.
> 
> This patch resolves the leak by kfree()'ing the allocated memory
> before the return.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Nice catch. Thanks.

Acked-by: Arend van Spriel <arend@broadcom.com>

Gr. AvS
