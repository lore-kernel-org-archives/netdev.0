From: Andrew Morton <akpm@digeo.com>
Subject: Re: [RFC][PATCH] net drivers and cache alignment
Date: Sat, 07 Dec 2002 15:42:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF28748.186AB31F@digeo.com>
References: <3DF2844C.F9216283@digeo.com> <20021207.153045.26640406.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
>    From: Andrew Morton <akpm@digeo.com>
>    Date: Sat, 07 Dec 2002 15:29:16 -0800
> 
>    Jeff Garzik wrote:
>    > Attached is cut #2.  Thanks for all the near-instant feedback so far :)
>    >   Andrew, does the attached still need padding on SMP?
> 
>    It needs padding _only_ on SMP.  ____cacheline_aligned_in_smp.
> 
> non-smp machines lack L2 caches?  That's new to me :-)
> 
> More seriously, there are real benefits on non-SMP systems.

Then I am most confused.  None of these fields will be put under
busmastering or anything like that, so what advantage is there in
spreading them out?
