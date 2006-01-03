From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] forcedeth: TSO fix for large buffers
Date: Tue, 03 Jan 2006 21:33:55 +0100
Message-ID: <43BADFB3.5050908@colorfullife.com>
References: <200512251451.jBPEpgNe018712@dbl.q-ag.de> <20051225.125742.65007619.davem@davemloft.net> <3E346722.7070304@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, manfred@dbl.q-ag.de,
	jgarzik@pobox.com, afu@fugmann.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932520AbWACUfW@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <3E346722.7070304@nvidia.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:

> If you look at the code, I do not set the NV_TX2_VALID bit (stored in 
> np->tx_flags) in the first tx descriptor

You are right: tx_flags starts as 0 and is only set to np->tx_flags 
after the first tx descriptor was set up.
I overlooked that point, sorry.

Jeff: Could you add the patch to your tree?

--
    Manfred
