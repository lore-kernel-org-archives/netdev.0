From: jamal <hadi@cyberus.ca>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.49
Date: Fri, 29 Nov 2002 07:56:51 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211290753590.3643-100000@shell.cyberus.ca>
References: <3DE33D6D.25B9C9B4@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DE33D6D.25B9C9B4@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 26 Nov 2002, Stefan Rompf wrote:

> Hi David,
>
> I've updated my RFC2863 operstatus and userspace forwarding patch to
> 2.5.49. As discussion on netdev seems to be complete, I need some
> comment from your side.
>

Stefan,
Just thought of something, it may be a little tricky but valuable and
i am not quiet sure if it should part of your patch: We probably need to
flush the qdiscs software queues; maybe even the DMA ring i.e simulate
admin down followed by admin up.
Thoughts?

cheers,
jamal
