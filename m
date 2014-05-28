From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Fw: [Bug 76781] New: unable to handle NULL in xfrm_input+0x173,
 fatal exception in interrupt
Date: Wed, 28 May 2014 23:34:19 +0200
Message-ID: <5386565B.7060209@redhat.com>
References: <20140528140147.7eaa538e@nehalam.linuxnetplumber.net> <1401312501.3645.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38319 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751830AbaE1Ve1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2014 17:34:27 -0400
In-Reply-To: <1401312501.3645.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2014 11:28 PM, Eric Dumazet wrote:
> On Wed, 2014-05-28 at 14:01 -0700, Stephen Hemminger wrote:
>>
>> Begin forwarded message:
>>
>> Date: Fri, 23 May 2014 00:07:48 -0700
>> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
>> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
>> Subject: [Bug 76781] New: unable to handle NULL in xfrm_input+0x173, fatal exception in interrupt
>>
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=76781
>>
>>              Bug ID: 76781
>>             Summary: unable to handle NULL in xfrm_input+0x173, fatal
>>                      exception in interrupt
>>             Product: Networking
>>             Version: 2.5
>>      Kernel Version: 3.15.0-rc6
>>            Hardware: x86-64
>>                  OS: Linux
>>                Tree: Mainline
>>              Status: NEW
>>            Severity: normal
>>            Priority: P1
>>           Component: Other
>>            Assignee: shemminger@linux-foundation.org
>>            Reporter: cate@cateee.net
>>          Regression: No
>>
>> See also the fatal oops in:
>>
>> http://cateee.net/kernel/IMG_20140522_225238.jpg
>> http://cateee.net/kernel/IMG_20140523_082629.jpg
>>
>>
>> It seems it happens "often": twice in last few hours I used the new kernels.
>> (the first oops was with 3.15.0-rc5-00270-gfba69f0)
>>
>> I had also usual debian unstable updates, and I just finished to instal aiccu
>> (a sixxs program for dynamic ip6to4, so I'm not sure it is a recent bug or just
>> I forced it to appear in very last HEAD.
>
> Right, commit 61622cc6f29034d0 is buggy.

Steffen already replied some days ago here:

   http://www.spinics.net/lists/netdev/msg283705.html
