From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/6] netns support in the kobject layer
Date: Mon, 17 May 2010 15:37:22 -0700
Message-ID: <m1hbm6f93x.fsf@fess.ebiederm.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	<m1d3xb4239.fsf@fess.ebiederm.org> <20100506200404.GA21805@kroah.com>
	<20100515.232643.212422307.davem@davemloft.net>
	<20100517181133.GB18721@kroah.com> <m1zkzyfdob.fsf@fess.ebiederm.org>
	<20100517210318.GA6170@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	kay.sievers@vrfy.org, linux-kernel@vger.kernel.org, tj@kernel.org,
	cornelia.huck@de.ibm.com, eric.dumazet@gmail.com, bcrl@lhnet.ca,
	serue@us.ibm.com, netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100517210318.GA6170@suse.de> (Greg KH's message of "Mon\, 17 May 2010 14\:03\:18 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH <gregkh@suse.de> writes:

> On Mon, May 17, 2010 at 01:58:44PM -0700, Eric W. Biederman wrote:
>> Greg KH <greg@kroah.com> writes:
>> 
>> > On Sat, May 15, 2010 at 11:26:43PM -0700, David Miller wrote:
>> >> From: Greg KH <greg@kroah.com>
>> >> Date: Thu, 6 May 2010 13:04:04 -0700
>> >> 
>> >> > On Tue, May 04, 2010 at 05:35:54PM -0700, Eric W. Biederman wrote:
>> >> >> 
>> >> >> With the tagged sysfs support finally merged into Greg's tree,
>> >> >> it is time for the last little bits of work to get the kobject
>> >> >> layer and network namespaces to play together properly.
>> >> >> 
>> >> >> These patches are roughly evenly divided between network layer work
>> >> >> and sysfs layer work.  Last time this conundrum came up I believe
>> >> >> we decided that the easiest way to handle this was for Greg to carry
>> >> >> all of the patches.  David, Greg does that still make sense?
>> >> > 
>> >> > That's fine, if I get David's ack on these.
>> >> 
>> >> Looks good to me:
>> >> 
>> >> Acked-by: David S. Miller <davem@davemloft.net>
>> >
>> > Ok.  Eric, can you resend these to me when .35-rc1 is out so I can queue
>> > them up then to get some testing in linux-next so that they can make it
>> > into .36?
>> 
>> Grumble.  Grumble. Grumble.
>> 
>> If I must I will resend these, but these patches are already in
>> production use, and I had them to you weeks before the merge window
>> closed.
>
> Yes, but they were not reviewed by the network maintainer until after
> the merge window closed.

Strictly speaking the day before but I get your point.

>  I already have your sysfs-namespace patches
> queued up for .35, and that's a big enough change for me to feel
> comfortable with at the moment.
>
>> Is there no way we can get these in for 2.6.35?
>
> No, sorry.  One thing at a time please.

Sure.

If we are going to push this last bit off until the 2.6.36 time frame
Dave, Greg mind if I flip around who I send these patches to?

The big dependency is the sysfs-namespace patches which will be in
2.6.35, and if the patches get into net-next as well as linux-next
there will be a larger number of potential testers.

Eric
