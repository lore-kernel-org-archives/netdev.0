From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC][PATCH] net drivers and cache alignment
Date: Sat, 07 Dec 2002 15:30:45 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021207.153045.26640406.davem@redhat.com>
References: <20021207.144004.45605764.davem@redhat.com>
	<3DF27EE7.4010508@pobox.com>
	<3DF2844C.F9216283@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@digeo.com
In-Reply-To: <3DF2844C.F9216283@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andrew Morton <akpm@digeo.com>
   Date: Sat, 07 Dec 2002 15:29:16 -0800

   Jeff Garzik wrote:
   > Attached is cut #2.  Thanks for all the near-instant feedback so far :)
   >   Andrew, does the attached still need padding on SMP?
   
   It needs padding _only_ on SMP.  ____cacheline_aligned_in_smp.
   
non-smp machines lack L2 caches?  That's new to me :-)

More seriously, there are real benefits on non-SMP systems.
