From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] [PATCH 2/3] tg3 netpoll hook
Date: Sat, 04 Oct 2003 23:11:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F7F8BDF.5000903@pobox.com>
References: <20031003014505.GS1897@waste.org> <3F7F857D.5010504@pobox.com> <20031005025512.GF13573@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20031005025512.GF13573@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> Have an opinion on s/->poll_controller/->netpoll/?


I have an opinion, yes :)  which I despise myself for holding...

I don't like either name, but don't have any better suggestions either, 
besides something extremely verbose like ->process_hw_events().

"poll_controller" is annoying because (a) it's way too close to NAPI, 
but (b) it's a reasonably accurate description of what it does.

I think "netpoll" is even worse...  It describes who calls it, not what 
it does.

	Jeff
