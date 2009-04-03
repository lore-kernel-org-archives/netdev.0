From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 15:02:22 +0300
Message-ID: <49D5FACE.3010302@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <49D5EBE1.8030200@redhat.com> <49D5ED11.2000800@redhat.com> <20090403111242.GA10200@gondor.apana.org.au> <49D5F6FC.5090401@redhat.com> <20090403114828.GA10465@gondor.apana.org.au> <49D5F8DA.20400@redhat.com> <20090403115546.GA10575@gondor.apana.org.au>
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
In-Reply-To: <20090403115546.GA10575@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Apr 03, 2009 at 02:54:02PM +0300, Avi Kivity wrote:
>   
>> It doesn't copy and queue the packet?  We use O_NONBLOCK and poll() so  
>> we can tell when we can queue without blocking.
>>     
>
> Well netif_rx queues the packet, but netif_rx_ni is netif_rx plus
> an immediate flush.
>   

But it flushes the tap device, the packet still has to go through the 
bridge + real interface?

Even if it's queued there, I want to know when the packet is on the 
wire, not on some random software or hardware queue in the middle.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

