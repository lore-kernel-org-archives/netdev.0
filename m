From: Keith Owens <kaos@ocs.com.au>
Subject: Re: [RFC] [PATCH 2/3] tg3 netpoll hook
Date: Sun, 05 Oct 2003 13:16:19 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <31674.1065323779@ocs3.intra.ocs.com.au>
References: <3F7F8BDF.5000903@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, netdev@oss.sgi.com,
        Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-reply-to: Your message of "Sat, 04 Oct 2003 23:11:27 -0400."
             <3F7F8BDF.5000903@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 04 Oct 2003 23:11:27 -0400, 
Jeff Garzik <jgarzik@pobox.com> wrote:
>Matt Mackall wrote:
>> Have an opinion on s/->poll_controller/->netpoll/?
>I don't like either name, but don't have any better suggestions either, 
>besides something extremely verbose like ->process_hw_events().
>
>"poll_controller" is annoying because (a) it's way too close to NAPI, 
>but (b) it's a reasonably accurate description of what it does.
>
>I think "netpoll" is even worse...  It describes who calls it, not what 
>it does.

->polled_io ?
