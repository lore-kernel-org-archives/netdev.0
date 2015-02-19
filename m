From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RESEND PATCH] ipv4: ip_check_defrag should correctly check
 return value of skb_copy_bits
Date: Thu, 19 Feb 2015 06:50:15 -0800
Message-ID: <1424357415.4942.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424337992-8854-1-git-send-email-al.drozdov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	ideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>
To: Alexander Drozdov <al.drozdov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424337992-8854-1-git-send-email-al.drozdov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-02-19 at 12:26 +0300, Alexander Drozdov wrote:
> skb_copy_bits() returns zero on success and a negative value on error,
> so it is needed to invert the condition in ip_check_defrag().
> 
> Fixes: 1bf3751ec90c ("ipv4: ip_check_defrag must not modify skb before unsharing")
> Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Cc: Johannes Berg <johannes.berg@intel.com>
> ---
>  net/ipv4/ip_fragment.c | 2 +-

No need to resend, your first patch is still active in patchwork.
David is probably traveling from Ottawa.

vi +100  Documentation/networking/netdev-FAQ.txt

Q: I sent a patch and I'm wondering what happened to it.  How can I tell
   whether it got merged?

A: Start by looking at the main patchworks queue for netdev:

        http://patchwork.ozlabs.org/project/netdev/list/

   The "State" field will tell you exactly where things are at with
   your patch.

Q: The above only says "Under Review".  How can I find out more?

A: Generally speaking, the patches get triaged quickly (in less than 48h).
   So be patient.  Asking the maintainer for status updates on your
   patch is a good way to ensure your patch is ignored or pushed to
   the bottom of the priority list.
