From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Fri, 5 Feb 2016 11:01:22 +0100
Message-ID: <56B472F2.6080101@stressinduktion.org>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <20160203143133.1b70bcb5@redhat.com> <20160203133356.GA2219@nanopsycho.orion>
 <56B219FA.7080208@iogearbox.net> <56B35089.4000707@stressinduktion.org>
 <20160204132622.GB2198@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:58180 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750811AbcBEKBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 05:01:32 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 26BAA20BA5
	for <netdev@vger.kernel.org>; Fri,  5 Feb 2016 05:01:29 -0500 (EST)
In-Reply-To: <20160204132622.GB2198@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.02.2016 14:26, Jiri Pirko wrote:
> Thu, Feb 04, 2016 at 02:22:17PM CET, hannes@stressinduktion.org wrote:
>> On 03.02.2016 16:17, Daniel Borkmann wrote:
>>> On 02/03/2016 02:33 PM, Jiri Pirko wrote:
>>>> Wed, Feb 03, 2016 at 02:31:33PM CET, brouer@redhat.com wrote:
>>>>> On Wed,  3 Feb 2016 11:47:56 +0100
>>>>> Jiri Pirko <jiri@resnulli.us> wrote:
>>>>>> From: Jiri Pirko <jiri@mellanox.com>
>>> [...]
>>>>>> It is available here:
>>>>>> https://github.com/jpirko/devlink
>>>>>
>>>>> IHMO this very short command name "dl" is not an advantage.  It is
>>>>> simply too unspecific and short for a good Google search.  E.g. when
>>>>> searching for good examples for using "dl".  I think "devlink" would be
>>>>> better.  If you like short commands do: alias dl="devlink"
>>>>
>>>> I was thinking about using "devlink". Decided to go with shortened
>>>> version so this is in-line with "ip". But you have a point.
>>>
>>> Btw, if you add this tool into iproute2 (which would be preferred), then
>>> probably dl should be ok (and easier retrievable in that relation).
>>
>> This doesn't seem to be too much related to networking? Why can't something
>> like this be in sysfs?
>
> It is related to networking quite bit. There has been couple of
> iteration of this, including sysfs and configfs implementations. There
> has been a consensus reached that this should be done by netlink. I
> believe netlink is really the best for this purpose. Sysfs is not a good
> idea.

Okay. I see it more as changing mode of operation of hardware and thus 
has not really anything to do with networking. If you say you change 
ethernet to infiniband it has something to do with networking, sure. But 
I am fine with this, I just thought the code size could be reduced by 
adding this to sysfs quite a lot. I don't have a strong opinion on this.

The attributes seem to reassemble sysfs quite a lot and at the same time 
implement a dependency on the ifindex which in a relational model is not 
really possible? Do infiniband devices have ifindexes? Names for 
infiniband and netdev are hardcoded? Shouldn't an interface to deliver 
hw msg be better in terms of streaming than using netlink?

Thanks,
Hannes
