From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]: Adjust qlen when grafting in multiple qdiscs
Date: Mon, 17 Nov 2003 15:40:32 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB8DDE0.1070105@trash.net>
References: <3FB3996A.6080008@trash.net> <1069076786.1075.19.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1069076786.1075.19.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal,

I've tested tbf and prio changes before and after. Unfortunately I've 
never used dsmark so I didn't test this part. I did try to make sure
my changes make sense, and I still don't see why this wouldn't be
correct. dsmark increments sch->q.qlen in enqueue, so it needs to
adjust it in dsmark_graft if the old queue is non-empty. If this is
wrong, please enlighten me so I can fix my patch.

Best regards,
Patrick


jamal wrote:

>Did you test some of this stuff or just did a mass-edit? I havent paid
>attention to all the details, but what would decrementing sch->q.qlen on
>grafting mean on a dsmark? 
>
>cheers,
>jamal
>
>  
>
