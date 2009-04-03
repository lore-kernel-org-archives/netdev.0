From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 14:46:54 +0300
Message-ID: <49D5F72E.2060804@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <49D5EBE1.8030200@redhat.com> <20090403111854.GA11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gerd Hoffmann <kraxel@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, ghaskins@novell.com,
	anthony@codemonkey.ws, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090403111854.GA11935@one.firstfloor.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>> Check shared ring status when stuffing a request.  If there are requests
>>     
>
> That means you're bouncing cache lines all the time. Probably not a big
> issue on single socket but could be on larger systems.
>   

That's why I'd like requests to be handled on the vcpu thread rather 
than an auxiliary thread.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

