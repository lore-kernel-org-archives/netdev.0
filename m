From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 15:18:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F60CA6D.9090503@pobox.com>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
> * Change the default number of Tx descriptors from 256 to 1024.
>   Data from [ricardoz@us.ibm.com] shows it's easy to overrun
>   the Tx desc queue.


All e1000 patches applied except this one.

Of _course_ it's easy to overrun the Tx desc queue.  That's why we have 
a TX queue sitting on top of the NIC's hardware queue.  And TCP socket 
buffers on top of that.  And similar things.

Descriptor increases like this are usually the result of some sillyhead 
blasting out UDP packets, and then wondering why he sees packet loss on 
the local computer (the "blast out packets" side).

You're just wasting memory.

	Jeff
