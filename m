From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: Thu, 31 Mar 2005 15:28:16 -0800
Message-ID: <424C8790.6060203@hp.com>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>	<20050331120410.7effa94d@dxpl.pdx.osdl.net>	<1112303431.1073.67.camel@jzny.localdomain>	<424C6A98.1070509@hp.com>	<1112305084.1073.94.camel@jzny.localdomain>	<424C7CDC.8050801@hp.com> <424C81B8.6090709@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
In-Reply-To: <424C81B8.6090709@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>> I "never" see that because I always bind a NIC to a specific CPU :)  
>> Just about every networking-intensive benchmark report I've seen has 
>> done the same.
> 
> 
> Just a reminder that the networking-benchmark world and
> the real networking deployment world have a less than desirable
> intersection (which I know you know only too well, Rick ;)).

Touche :)

> How often do people use affinity? How often do they really tune
> the system for their workloads? 

Not as often as they should.

 > How often do they turn off things like SACK etc?

Well, I'm in an email discussion with someone who seems to bump their TCP 
windows quite large, and disable timestamps...

> Not very often in the real world. Designing OSs to
> do better at benchmarks is a different proposition than designing
> OSs to do well in the real world.

BTW what is the real world purpose of having the multiple CPU affinity of NIC 
interrupts?  I have to admit it seems rather alien to me.  (In the context of no 
onboard NIC smarts being involved that is)

>>> Note Linux is quiet resilient to reordering compared to other OSes (as
>>> you may know) but avoiding this is a better approach - hence my
>>> suggestion to use NAPI when you want to do serious TCP.
> 
> 
> The real killer for TCP is triggering fast retransmit
> unnecessarily

Agreed.  That is doubleplusungood.

rick
