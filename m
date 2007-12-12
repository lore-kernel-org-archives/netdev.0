From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [RFC] net: napi fix
Date: Wed, 12 Dec 2007 12:40:03 -0500
Message-ID: <47601CF3.6030802@myri.com>
References: <47601A73.5010804@myri.com> <20071212.093819.205755031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757818AbXLLRrk@vger.kernel.org>
In-Reply-To: <20071212.093819.205755031.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Andrew Gallatin <gallatin@myri.com>
> Date: Wed, 12 Dec 2007 12:29:23 -0500
> 
>> Is the netif_running() check even required?
> 
> No, it is not.
> 
> When a device is brought down, one of the first things
> that happens is that we wait for all pending NAPI polls
> to complete, then block any new polls from starting.

Great, thanks.  I will submit a patch to remove the bogus
check.  This should fix myri10ge properly.


Thank you,

Drew
