From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] [PATCH 2/3] tg3 netpoll hook
Date: Sat, 04 Oct 2003 23:21:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F7F8E26.3080307@pobox.com>
References: <31674.1065323779@ocs3.intra.ocs.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>, netdev@oss.sgi.com,
        Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Keith Owens <kaos@ocs.com.au>
In-Reply-To: <31674.1065323779@ocs3.intra.ocs.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Keith Owens wrote:
> On Sat, 04 Oct 2003 23:11:27 -0400, 
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
>>Matt Mackall wrote:
>>
>>>Have an opinion on s/->poll_controller/->netpoll/?
>>
>>I don't like either name, but don't have any better suggestions either, 
>>besides something extremely verbose like ->process_hw_events().
>>
>>"poll_controller" is annoying because (a) it's way too close to NAPI, 
>>but (b) it's a reasonably accurate description of what it does.
>>
>>I think "netpoll" is even worse...  It describes who calls it, not what 
>>it does.
> 
> 
> ->polled_io ?


Not too bad...   Better than any suggestion of mine, at any rate :)

	Jeff
