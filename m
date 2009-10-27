From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] net: fold network name hash
Date: Tue, 27 Oct 2009 20:02:25 +0200
Message-ID: <200910272002.25384.opurdila@ixiacom.com>
References: <9986527.24561256620662709.JavaMail.root@tahiti.vyatta.com> <20091026.222428.80364204.davem@davemloft.net> <20091027102251.244ee681@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	viro@zeniv.linux.org.uk
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932086AbZJ0SFU@vger.kernel.org>
In-Reply-To: <20091027102251.244ee681@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 October 2009 19:22:51 you wrote:

> The full_name_hash does not produce a value that is evenly distributed
> over the lower 8 bits. This causes name hash to be unbalanced with large
> number of names.  A simple fix is to just fold in the higher bits
> with XOR.
> 
> This is independent of possible improvements to full_name_hash()
> in future.
> 

I can confirm that the distribution looks good now for our most common cases. 

Thanks,
tavi
