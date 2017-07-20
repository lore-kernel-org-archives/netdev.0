From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rds: Make sure updates to cp_send_gen can be
 observed
Date: Thu, 20 Jul 2017 15:33:19 -0700 (PDT)
Message-ID: <20170720.153319.615690739132189305.davem@davemloft.net>
References: <20170720102855.21961-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: Haakon.Bugge@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170720102855.21961-1-Haakon.Bugge@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Håkon Bugge <Haakon.Bugge@oracle.com>
Date: Thu, 20 Jul 2017 12:28:55 +0200

> cp->cp_send_gen is treated as a normal variable, although it may be
> used by different threads.
> 
> This is fixed by using {READ,WRITE}_ONCE when it is incremented and
> READ_ONCE when it is read outside the {acquire,release}_in_xmit
> protection.
> 
> Normative reference from the Linux-Kernel Memory Model:
> 
>     Loads from and stores to shared (but non-atomic) variables should
>     be protected with the READ_ONCE(), WRITE_ONCE(), and
>     ACCESS_ONCE().
> 
> Clause 5.1.2.4/25 in the C standard is also relevant.
> 
> Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
> Reviewed-by: Knut Omang <knut.omang@oracle.com>

Applied, thanks.
