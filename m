From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: gigabit ethernet
Date: Fri, 13 Feb 2004 13:31:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <402D424A.5060901@us.ibm.com>
References: <Pine.LNX.4.44.0402131116590.24993-100000@fast2.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: satya srikanth <satyasrikanth2001@yahoo.com>,
        "Xiaoliang (David) Wei" <weixl@caltech.edu>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
In-Reply-To: <Pine.LNX.4.44.0402131116590.24993-100000@fast2.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cheng Jin wrote:
> 
> I read somewhere that Intel SMP has cpu0 taking care of 
> all the hardware interrupts, but I don't know about softirqs.
> I think all softirqs related to the GbE are handled by the
> same cpu.

For incoming network packets, the hw interrupt handler simply
schedules a local softirq to handle the rest of the input
processing. So the softirq will execute on the same
CPU that the hw interrupt came in on.

thanks,
Nivedita
