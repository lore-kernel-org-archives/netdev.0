From: Casey Carter <Casey@Carter.net>
Subject: Re: Strange UDP binding behavior (SO_BINDTODEVICE)
Date: Tue, 07 Oct 2003 16:49:36 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F8334F0.4060205@Carter.net>
References: <20031005130154.5bd9d182.kevin@pheared.net>	<3F81F1CD.8050803@Carter.net>	<20031006210600.37da62c9.kevin@pheared.net>	<3F83276D.3070700@cs.uiuc.edu> <20031007170823.41ef2ff9.kevin@pheared.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casey Carter <ccarter@cs.uiuc.edu>, netdev@oss.sgi.com,
        linux-ha@lists.linux-ha.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Kevin Dwyer <kevin@pheared.net>
In-Reply-To: <20031007170823.41ef2ff9.kevin@pheared.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kevin Dwyer wrote:

>On Tue, 07 Oct 2003 15:51:57 -0500
>Casey Carter <ccarter@cs.uiuc.edu> wrote:
>
>  
>
>>IMHO, the delivery should weigh sk_bound_dev_if much more strongly (7
>>instead of 2), so that if-bound sockets are always favored over
>>non-if-bound.  I would be happy to submit the (trivial) patch to do so
>>if the networking gurus agree?
>>    
>>
>
>Any possibility of getting this behavior into 2.4 as well?  Albeit,
>without the scoring since that's obviously a new concept introduced by
>2.6. (Which I prefer; well done.)
>
>I confess that I don't know who to talk to about such a change.
>  
>
There is actually a similar ranking algorithm in 2.4, with a similar 
fix. I'll work up a patch and resubmit to netdev in hopes that one of 
the gurus will pick it up.

-- 
Casey Carter
Casey@Carter.net
ccarter@cs.uiuc.edu
AIM: cartec69
