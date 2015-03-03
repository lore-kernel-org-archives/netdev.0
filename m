From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bcm63xx_enet: fix poll callback.
Date: Tue, 03 Mar 2015 08:32:26 -0800
Message-ID: <1425400346.5130.189.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425383112-23851-1-git-send-email-nschichan@freebox.fr>
	 <1425389399.5130.169.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425390142.5130.173.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F5DCAF.9070102@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Schichan <nschichan@freebox.fr>,
	"David S. Miller" <davem@davemloft.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	Felipe Balbi <balbi@ti.com>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F5DCAF.9070102@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 08:09 -0800, Alexander Duyck wrote:

> This rmb() can probably be replaced with a dma_rmb() since it is just a 
> coherent/coherent ordering you are concerned with based on the comment.

Right, but this patch would be a stable candidate, where dma_rmb() does
not exist yet.
