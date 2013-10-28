From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: RE: [PATCH 7/8] rds: Pass pointers to virt_to_page(), not integers
Date: Mon, 28 Oct 2013 07:22:55 -0700 (PDT)
Message-ID: <72e26ba4-7b4f-4b64-b58c-0042cbe89202@default>
References: <1382910437.2994.43.camel@deadeye.wl.decadent.org.uk>
 <1382910856.2994.51.camel@deadeye.wl.decadent.org.uk>
 <20131028.002654.404759341390215962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131028.002654.404759341390215962.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Sunday, October 27, 2013 11:27 PM
To: ben@decadent.org.uk
Cc: Venkat Venkatsubra; linux-kernel@vger.kernel.org; rds-devel@oss.oracle.com; netdev@vger.kernel.org
Subject: Re: [PATCH 7/8] rds: Pass pointers to virt_to_page(), not integers

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 27 Oct 2013 21:54:16 +0000

> Most architectures define virt_to_page() as a macro that casts its 
> argument such that an argument of type unsigned long will be accepted 
> without complaint.  However, the proper type is void *, and passing 
> unsigned long results in a warning on MIPS.
> 
> Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

This looks fine:

Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
