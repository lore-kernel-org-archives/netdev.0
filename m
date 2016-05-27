From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 extension header privileges
Date: Fri, 27 May 2016 11:53:46 +0200
Message-ID: <614c9a42-02c1-052a-52b6-289818bf757b@stressinduktion.org>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
 <1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
 <20160521015604.GD2452@oracle.com>
 <1463823275.2335717.614453105.5011B2EE@webmail.messagingengine.com>
 <CALx6S36V8Bv1R+rKWB7u=Y8371aT7JybDdkEErrRtw_bsHrMaA@mail.gmail.com>
 <6a889c73-efb1-7d4c-ba33-8b076378fcb7@stressinduktion.org>
 <CALx6S36scChuaS+uygAu4zk9gEz_qA=BSwX4f=kC_YXurTpMqw@mail.gmail.com>
 <f007389f-4ed1-2b67-69b5-28cd999264b9@stressinduktion.org>
 <20160521174438.GA27990@oracle.com>
 <82086299-ddb2-8acc-1286-5a1a7b2bf311@stressinduktion.org>
 <20160522115605.GA30516@oracle.com>
 <CALx6S358LkPTz9kzWDuveZgDFjaL7AbgwgcVLP4iyC6Bvd3yBg@mail.gmail.com>
 <CALx6S3580cJPWskNYD_xYbveXTdOzPVB8axXh471jDVzm94PhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Tom Herbert <tom@herbertland.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:46399 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932454AbcE0Jxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 05:53:49 -0400
In-Reply-To: <CALx6S3580cJPWskNYD_xYbveXTdOzPVB8axXh471jDVzm94PhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.05.2016 20:42, Tom Herbert wrote:
> On Mon, May 23, 2016 at 11:11 AM, Tom Herbert <tom@herbertland.com> wrote:
>> On Sun, May 22, 2016 at 4:56 AM, Sowmini Varadhan
>> <sowmini.varadhan@oracle.com> wrote:
>>>
>>>>> Tom Herbert wrote:
>>>>>>>>> If you don't mind I'll change this to make specific options are
>>>>>>>>> privileged and not all hbh and destopt. There is talk in IETF about
>>>>>>>>> reinventing IP extensibility within UDP since the kernel APIs don't
>>>>>>>>> allow setting EH. I would like to avoid that :-)
>>>
>>>> On 21.05.2016 19:46, Sowmini Varadhan wrote:
>>>>> Do you mean this
>>>>>   http://www.ietf.org/mail-archive/web/spud/current/msg00365.html
>>>
>>> On (05/22/16 03:08), Hannes Frederic Sowa wrote:
>>>> Hmm, haven't read carefully but isn't that just plain TCP in UDP? I saw
>>>> extension headers mentioned but haven't grasped why they deem necessary.
>>>
>>> Tom should clarify what he meant, but perhaps he was referring to other
>>> threads discussing v6 EH. In any case, I dont think the way least-privileges
>>> for EH are implemented in an OS is directly relevant or causational for
>>> whether or not the kernel should be bypassed - looks like there are a lot
>>> of other drafts floating around, arguing for implementing various tcp/ip
>>> protocols in uspace and beyond, motivated by various reasons.
>>>
>> It's a deployment conundrum. Suppose tomorrow that IANA registers some
>> new hpb option that would be useful to the network, but is of no
>> interest to the kernel other than it needs to be set in packets when
>> the user requests it. In the white list model, there is no problem
>> getting support for such a thing into the upstream kernel, the time
>> frame for that is one release cycle. Neither is there any problem
>> updating the apps to set the option, for instance we can update FB app
>> to do this within a week. The problem is that getting something into
>> the kernel does not make it useful, the kernel needs to actually be
>> deployed which is mostly out of our control (for those of us who don't
>> own the client platform). So get the options deployed on clients
>> (particularly Android), this takes much, much longer. And if the
>> feature requires explicit action do be enabled, like turning a sysctl,
>> it is going to take even longer possibly an indeterminate amount of
>> time to ever get enabled.
>>
> Thinking about this some more, the per option white list is a better
> approach. If we allow an open ended mechanism for applications to
> signal the network with arbitrary data (like user specified hbp
> options would be), then use of that mechanism will inevitably
> exploited by some authorities to force user to hand over private data
> about their communications. It's better to not build in back doors to
> security...

Sorry, Tom, can you try to explain again, I think I might not have
understood you correctly.

Thanks,
Hannes
