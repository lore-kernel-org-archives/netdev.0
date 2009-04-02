From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 19:54:21 +0300
Message-ID: <49D4EDBD.3050900@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <200904022243.21088.rusty@rustcorp.com.au> <49D4B4A3.5070008@novell.com> <49D4B87D.2000202@redhat.com> <20090402145018.GA816@gondor.apana.org.au> <49D4D301.2090209@redhat.com> <20090402154041.GA1774@gondor.apana.org.au> <49D4E072.2060003@redhat.com> <20090402160941.GB2173@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	Rusty Russell <rusty@rustcorp.com.au>, anthony@codemonkey.ws,
	andi@firstfloor.org, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090402160941.GB2173@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Apr 02, 2009 at 06:57:38PM +0300, Avi Kivity wrote:
>   
>> What if the guest sends N packets, then does some expensive computation  
>> (say the guest scheduler switches from the benchmark process to  
>> evolution).  So now we have the marker set at packet N, but the host  
>> will not see it until the guest timeslice is up?
>>     
>
> Well that's fine.  The guest will use up the remainder of its
> timeslice.  After all we only have one core/hyperthread here so
> this is no different than if the packets were held up higher up
> in the guest kernel and the guest decided to do some computation.
>
>   

3ms latency for ping?

(ping will always be scheduled immediately when the reply arrives if I 
understand cfs, so guest load won't delay it)

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

