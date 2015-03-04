From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bcm63xx_enet: fix poll callback.
Date: Wed, 04 Mar 2015 15:45:22 -0500 (EST)
Message-ID: <20150304.154522.665232561815766240.davem@davemloft.net>
References: <1425383112-23851-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tklauser@distanz.ch, balbi@ti.com,
	w-lkml@lebenslange-mailadresse.de, ebiederm@xmission.com,
	alexander.h.duyck@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nschichan@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425383112-23851-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Schichan <nschichan@freebox.fr>
Date: Tue,  3 Mar 2015 12:45:12 +0100

> In case there was some tx buffer reclaimed and not enough rx packets
> to consume the whole budget, napi_complete would not be called and
> interrupts would be kept disabled, effectively resulting in the
> network core never to call the poll callback again and no rx/tx
> interrupts to be fired either.
> 
> Fix that by only accounting the rx work done in the poll callback.
> 
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>

Applied.
