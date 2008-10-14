From: Don Porter <porterde@cs.utexas.edu>
Subject: Re: e1000 softirq load balancing
Date: Tue, 14 Oct 2008 18:46:11 -0500
Message-ID: <48F52F43.9040201@cs.utexas.edu>
References: <48F4ED7E.4070308@cs.utexas.edu> <20081014.125156.92616351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20081014.125156.92616351.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks David.

Would you mind giving me a bit of intuition why I can't have a 1:1 
mapping of CPUs to NICs? 

I am a bit out of my depth here, but I'd like to learn.

Best,
Don

David Miller wrote:
> From: Don Porter <porterde@cs.utexas.edu>
> Date: Tue, 14 Oct 2008 14:05:34 -0500
>
>   
>> It seems to me that with 4 independent NICs and plenty of CPUs to
>> spare, I ought to be able to assign one softirq daemon to each NIC
>> rather than funnelling all of the traffic through 1 or 2.
>>     
>
> Traffic doesn't get distributed unless the NIC has support
> for RX flow seperation and PCI MSI-X interrupts.  Your NICs
> do not.
>
> So no matter how hard you try, each NIC is going to have it's
> packets processed essentially on one cpu.
>   

