From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]: Adjust qlen when grafting in multiple qdiscs
Date: Mon, 17 Nov 2003 22:10:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB93947.2090804@trash.net>
References: <3FB3996A.6080008@trash.net> <1069076786.1075.19.camel@jzny.localdomain> <3FB8DDE0.1070105@trash.net> <1069081153.1022.20.camel@jzny.localdomain> <3FB8F3BF.6050509@trash.net> <1069090210.1022.64.camel@jzny.localdomain> <20031117163834.V1330@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Werner Almesberger <werner@almesberger.net>
In-Reply-To: <20031117163834.V1330@almesberger.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Werner Almesberger wrote:

>Patrick, was the experiment "I've now verified experimentally the
>problem also exists in dsmark" done with or without your
>"sch->q.qlen -= (*old)->q.qlen;" patch ? This looks just like the
>behaviour I'd expect your patch to fix, no ?
>  
>
Correct, it was done without the patch and the patch is supposed to fix
it. I'm going to send a new version which just sets q.qlen to 0 later.

Best regards,
Patrick


>- Werner
>
>  
>
