From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 13:37:16 -0500
Message-ID: <41C3275C.2010505@tmr.com>
References: <41C2FF99.3020908@tmr.com><Xine.LNX.4.44.0412170144410.12579-100000@thoron.boston.redhat.com> <Pine.LNX.4.61.0412171108340.4216@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@redhat.com>, Patrick McHardy <kaber@trash.net>,
        Bryan Fulton <bryan@coverity.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-os@analogic.com
In-Reply-To: <Pine.LNX.4.61.0412171108340.4216@chaos.analogic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

linux-os wrote:
> On Fri, 17 Dec 2004, Bill Davidsen wrote:
> 
>> James Morris wrote:
>>
>>> On Fri, 17 Dec 2004, Patrick McHardy wrote:
>>>
>>>
>>>> James Morris wrote:
>>>>
>>>>
>>>>> This at least needs CAP_NET_ADMIN.
>>>>>
>>>>
>>>> It is already checked in do_ip6t_set_ctl(). Otherwise anyone could
>>>> replace iptables rules :)
>>>
>>>
>>>
>>> That's what I meant, you need the capability to do anything bad :-)
>>
>>
>> Are you saying that processes with capability don't make mistakes? 
>> This isn't a bug related to untrusted users doing privileged 
>> operations, it's a case of using unchecked user data.
>>
> 
> But isn't there always the possibility of "unchecked user data"?
> I can, as root, do `cp /dev/zero /dev/mem` and have the most
> spectacular crask you've evet seen. I can even make my file-
> systems unrecoverable.

But that's not the type of thing you would do by accident. The kernel 
can't protect against deliberate abuse by trusted users, nor should it. 
But the type of problem caused by an application program bug can, and I 
believe should, be caught.

The difference between "oops" and "take that!"

-- 
    -bill davidsen (davidsen@tmr.com)
"The secret to procrastination is to put things off until the
  last possible moment - but no longer"  -me
