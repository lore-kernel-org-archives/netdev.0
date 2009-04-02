From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 19:51:53 +0300
Message-ID: <49D4ED29.3000806@redhat.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D4CB38.5030205@redhat.com> <49D4DA54.3090401@novell.com> <49D4DE82.5020306@redhat.com> <20090402160625.GA2173@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	Patrick Mullaney <pmullaney@novell.com>, anthony@codemonkey.ws,
	andi@firstfloor.org, Peter Morreale <PMorreale@novell.com>,
	rusty@rustcorp.com.au, agraf@suse.de, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090402160625.GA2173@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Apr 02, 2009 at 06:49:22PM +0300, Avi Kivity wrote:
>   
>> I still think you want one MSI per device rather than one MSI per vbus,  
>> to avoid scaling problems on large guest.  After Herbert's let loose on  
>> the code, one MSI per queue.
>>     
>
> Yes, one MSI per TX queue, and one per RX queue :)
>
>   

We're currently limited to 1024, so go wild :)

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

