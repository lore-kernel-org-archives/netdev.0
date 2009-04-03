From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 14:46:04 +0300
Message-ID: <49D5F6FC.5090401@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <49D5EBE1.8030200@redhat.com> <49D5ED11.2000800@redhat.com> <20090403111242.GA10200@gondor.apana.org.au>
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
In-Reply-To: <20090403111242.GA10200@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Apr 03, 2009 at 02:03:45PM +0300, Avi Kivity wrote:
>   
>> If the host is able to consume a request immediately, and the guest is  
>> not able to batch requests, this breaks down.  And that is the current  
>> situation.
>>     
>
> Hang on, why is the host consuming the request immediately? It
> has to write the packet to tap, which then calls netif_rx_ni so
> it should actually go all the way, no?
>   

The host writes the packet to tap, at which point it is consumed from 
its point of view.  The host would like to mention that if there was an 
API to notify it when the packet was actually consumed, then it would 
gladly use it.  Bonus points if this involves not copying the packet.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

