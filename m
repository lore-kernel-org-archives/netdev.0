From: Phillip Susi <psusi@cfl.rr.com>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Wed, 26 Jul 2006 16:21:36 -0400
Message-ID: <44C7CED0.5020509@cfl.rr.com>
References: <1153905495613@2ka.mipt.ru> <11539054952574@2ka.mipt.ru> <20060726100431.GA7518@infradead.org> <20060726.031247.98341392.davem@davemloft.net> <20060726101539.GA8711@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from iriserv.iradimed.com ([69.44.168.233]:8401 "EHLO iradimed.com")
	by vger.kernel.org with ESMTP id S1161031AbWGZUVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 16:21:25 -0400
To: Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org
In-Reply-To: <20060726101539.GA8711@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
>> Networking and disk AIO have significantly different needs.
>>
>> Therefore, I really don't see it as reasonable to expect
>> a merge of these two things.  It doesn't make any sense.
> 
> I'm not sure about that.  The current aio interface isn't exactly nice
> for disk I/O either.  I'm more than happy to have a discussion about
> that aspect.
> 


I agree that it makes perfect sense for a merger because aio and 
networking have very similar needs.  In both cases, the caller hands the 
kernel a buffer and wants the kernel to either fill it or consume it, 
and to be able to do so asynchronously.  You also want to maximize 
performance in both cases by taking advantage of zero copy IO.

I wonder though, why do you say the current aio interface isn't nice for 
disk IO?  It seems to work rather nicely to me, and is much better than 
the posix aio interface.

