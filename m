From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Refine IPv6 Address Validation Timer
Date: Fri, 27 Sep 2002 18:20:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927.182001.122314480.davem@redhat.com>
References: <20020928.011439.108856769.yoshfuji@linux-ipv6.org>
	<200209271639.UAA21514@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209271639.UAA21514@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Fri, 27 Sep 2002 20:39:45 +0400 (MSD)
   
   > (do I need to resend complete patch?)
   
   No, I think. Deletion of bad debugging is easier to make after patching.

I've applied the patch with the time_after() debugging check
removed to both 2.4.x and 2.5.x

If, after discussion, the "HZ --> HZ/2" change needs to be made, just
send another patch on top of previous one, thanks.
