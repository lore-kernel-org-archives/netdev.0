From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: patch sysfs-implement-sysfs-tagged-directory-support.patch added to gregkh-2.6 tree
Date: Thu, 29 Apr 2010 22:24:55 -0700
Message-ID: <m1aaslbjh4.fsf@fess.ebiederm.org>
References: <12725729473590@kroah.org> <4BDA5A2D.6080904@kernel.org>
	<20100430044522.GA29845@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, bcrl@lhnet.ca, benjamin.thery@bull.net,
	cornelia.huck@de.ibm.com, eric.dumazet@gmail.com,
	kay.sievers@vrfy.org, netdev@vger.kernel.org, serue@us.ibm.com
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38989 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932964Ab0D3RRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:17:01 -0400
In-Reply-To: <20100430044522.GA29845@suse.de> (Greg KH's message of "Thu\, 29 Apr 2010 21\:45\:22 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <gregkh@suse.de> writes:

> On Fri, Apr 30, 2010 at 06:18:53AM +0200, Tejun Heo wrote:
>> On 04/29/2010 10:29 PM, gregkh@suse.de wrote:
>> > 
>> > This is a note to let you know that I've just added the patch titled
>> > 
>> >     Subject: sysfs: Implement sysfs tagged directory support.
>> > 
>> > to my gregkh-2.6 tree.  Its filename is
>> > 
>> >     sysfs-implement-sysfs-tagged-directory-support.patch
>> > 
>> > This tree can be found at 
>> >     http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/
>> 
>> I wish at least more comments are added before it goes mainline.  I
>> don't really understand the current form.
>
> Ok, that's fine with me, I'll pull it back out.

?????

Tejun you have offered nothing constructive to the review, except looking
and saying you don't understand what is going on.

I have a tree posted with all of my code.  I have given snippets of the
pieces yet to be merged, and still your reaction is you don't understand
please break it down for you in itty-bitty little pieces, that you don't
need to think about it, to understand it.

Tejun I think for the code to make any sense to you I would need to rip
out out and/or rewrite the kobject layer, and possible the device
model code as well.

Tejun I'm sorry you can't understand the code, and I'm sorry the code
may be over-general.  In part that is because making the code
over-general is what you asked for when reviewing it the first time.


Greg I have not gotten any constructive feedback.  Not a specific
please fix/or comment a specific thing.  Not a comment that
says something is a bug and just wrong.  The closest I have gotten
is a request to make the code even more complicated and intrusive,
and harder to keep correct by adding an ns member to kobjects
which comes to 3 copies of the same state for the same objects
which ultimately is more difficult to keep in sync.

I am more than happy to improve the code, but at this point I really
think the code needs to be merged so people are forced to deal with
it, instead of saying "I don't understand the code" in the review and
blocking the merge.  I don't think the code will improve any more by
being out of tree.

Eric
