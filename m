From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Submission for S2io 10GbE driver
Date: Thu, 19 Feb 2004 22:30:00 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40357F38.6040701@pobox.com>
References: <002e01c3f75d$a1413410$8e10100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: raghavendra.koushik@wipro.com, leonid.grossman@s2io.com,
        netdev@oss.sgi.com, raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan arakali <ravinandan.arakali@s2io.com>
In-Reply-To: <002e01c3f75d$a1413410$8e10100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

ravinandan arakali wrote:
> Hi Jeff,
> Since the whole nic structure is zeroed out initially, the
> "block_virt_addr" is initially NULL. So, if the allocation
> succeeds, it will hold a non-NULL value.
> So, in the freeSharedMem() if we check for it's non-NULL
> value and free it, we should be okay. Do you agree ?


Yes, agreed, sorry if I was not clear earlier.

	Jeff
