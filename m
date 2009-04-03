From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 14:54:02 +0300
Message-ID: <49D5F8DA.20400@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <49D5EBE1.8030200@redhat.com> <49D5ED11.2000800@redhat.com> <20090403111242.GA10200@gondor.apana.org.au> <49D5F6FC.5090401@redhat.com> <20090403114828.GA10465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gerd Hoffmann <kraxel@redhat.com>, ghaskins@novell.com,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090403114828.GA10465@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Apr 03, 2009 at 02:46:04PM +0300, Avi Kivity wrote:
>   
>> The host writes the packet to tap, at which point it is consumed from  
>> its point of view.  The host would like to mention that if there was an  
>> API to notify it when the packet was actually consumed, then it would  
>> gladly use it.  Bonus points if this involves not copying the packet.
>>     
>
> We're using write(2) for this, no? 

Yes.

> That should invoke netif_rx_ni
> which blocks until the packet is "processed", which usually means
> that it's placed on the NIC's hardware queue.
>   

It doesn't copy and queue the packet?  We use O_NONBLOCK and poll() so 
we can tell when we can queue without blocking.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

