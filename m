From: Ben Greear <greearb@candelatech.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 12:45:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F60D0F3.8080006@candelatech.com>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain> <3F60CA6D.9090503@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>, netdev@oss.sgi.com,
   ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F60CA6D.9090503@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Feldman, Scott wrote:
> 
>> * Change the default number of Tx descriptors from 256 to 1024.
>>   Data from [ricardoz@us.ibm.com] shows it's easy to overrun
>>   the Tx desc queue.
> 
> 
> 
> All e1000 patches applied except this one.
> 
> Of _course_ it's easy to overrun the Tx desc queue.  That's why we have 
> a TX queue sitting on top of the NIC's hardware queue.  And TCP socket 
> buffers on top of that.  And similar things.
> 
> Descriptor increases like this are usually the result of some sillyhead 
> blasting out UDP packets, and then wondering why he sees packet loss on 
> the local computer (the "blast out packets" side).

Erm, shouldn't the local machine back itself off if the various
queues are full?  Some time back I looked through the code and it
appeared to.  If not, I think it should.

> 
> You're just wasting memory.
> 
>     Jeff
> 
> 
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
