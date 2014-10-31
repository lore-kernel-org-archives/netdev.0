From: Meelis Roos <mroos@linux.ee>
Subject: Re: DMA-API warning from sunhme - unchecked dma_map_single error
Date: Fri, 31 Oct 2014 23:01:09 +0200 (EET)
Message-ID: <alpine.DEB.2.03.1410312258170.17220@cyber.ee>
References: <20141031205258.C3A2F7FE2E@ilves.cyber.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20141031205258.C3A2F7FE2E@ilves.cyber.ee>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> It seems to be correct warning - dma_map_single is used unchecked in
>> sunhme.c. I can try fixing it - the error handling will be the only
>> problem. Is it considered worthwile?
>
> Can you test this patch?

It works fine on E3500 where I had many debugging options on and caught 
it. No warnings, network still works.

-- 
Meelis Roos (mroos@linux.ee)
