From: Felix Radensky <felix@allot.com>
Subject: Re: e100 "Ferguson" release
Date: Tue, 05 Aug 2003 11:23:22 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2F697A.2020708@allot.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com>
 <3F2CA65F.8060105@pobox.com> <3F2CBA71.2070503@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jeff Garzik <jgarzik@pobox.com>,
   "Feldman, Scott" <scott.feldman@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've also noticed that the number of hard_start_xmit failures in e1000
has increased significantly in version 5.1.13-k1. In version 5.0.43-k1 the
number of failures was much smaller.

Felix.

Ben Greear wrote:

>
>
>
> With e100 and e1000, I see the very large numbers of the 
> hard_start_xmit failure
> when running very high packets-per-second rates (small packets).
> I see virtually no failures with tulip.  pktgen knows how to re-queue, 
> but it's
> curious it has to so often.  For code that does not requeue, this 
> could be even
> more of a bummer.
>
>
>
