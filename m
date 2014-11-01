From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/4] netns: allow to identify peer netns
Date: Sat, 01 Nov 2014 17:08:12 -0400 (EDT)
Message-ID: <20141101.170812.1034370067621331861.davem@davemloft.net>
References: <1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>
	<1414682728-4532-1-git-send-email-nicolas.dichtel@6wind.com>
	<871tpph03k.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <871tpph03k.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Date: Thu, 30 Oct 2014 11:41:03 -0700

> Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> writes:
> 
>> The goal of this serie is to be able to multicast netlink messages with an
>> attribute that identify a peer netns.
>> This is needed by the userland to interpret some informations contained in
>> netlink messages (like IFLA_LINK value, but also some other attributes in case
>> of x-netns netdevice (see also
>> http://thread.gmane.org/gmane.linux.network/315933/focus=316064 and
>> http://thread.gmane.org/gmane.linux.kernel.containers/28301/focus=4239)).
>>
>> Ids of peer netns are set by userland via a new genl messages. These ids are
>> stored per netns and are local (ie only valid in the netns where they are set).
>> To avoid allocating an int for each peer netns, I use idr_for_each() to retrieve
>> the id of a peer netns. Note that it will be possible to add a table (struct net
>> -> id) later to optimize this lookup if needed.
>>
>> Patch 1/4 introduces the netlink API mechanism to set and get these ids.
>> Patch 2/4 and 3/4 implements an example of how to use these ids in rtnetlink
>> messages. And patch 4/4 shows that the netlink messages can be symetric between
>> a GET and a SET.
>>
>> iproute2 patches are available, I can send them on demand.
> 
> A quick reply.  I think this patchset is in the right general direction.
> There are some oddball details that seem odd/awkward to me such as using
> genetlink instead of rtnetlink to get and set the ids, and not having
> ids if they are not set (that feels like a maintenance/usability challenge).
> 
> I would like to give your patches a deep review, but I won't be able to
> do that for a couple of weeks.  I am deep in the process of moving,
> and will be mostly offline until about the Nov 11th.

I'm going to mark this patch set 'deferred' in patchwork until things
move forward.

Thanks.
