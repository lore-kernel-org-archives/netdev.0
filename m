From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 18:00:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F60F07B.8060005@pobox.com>
References: <OFAFA77EE1.3E4E4085-ON85256D9E.00777520-86256D9E.0077947E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, greearb@candelatech.com,
   scott.feldman@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ricardo C Gonzalez <ricardoz@us.ibm.com>
In-Reply-To: <OFAFA77EE1.3E4E4085-ON85256D9E.00777520-86256D9E.0077947E@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ricardo C Gonzalez wrote:
> 
> 
>>IP transmit is black hole that may drop packets at any moment,
>>any datagram application not prepared for this should be prepared
>>for troubles or choose to move over to something like TCP.
> 
> 
> 
> As I said before, please do not make this a UDP issue. The data I sent out
> was taken using a TCP_STREAM test case. Please review it.


Your own words say "CPUs can fill TX queue".  We already know this. 
CPUs have been doing wire speed for ages.

	Jeff
