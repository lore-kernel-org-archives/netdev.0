From: Greg KH <greg@kroah.com>
Subject: Re: [RESEND] benet: BladeEngine 10Gb NIC driver
Date: Mon, 3 Nov 2008 12:46:19 -0800
Message-ID: <20081103204619.GA19936@kroah.com>
References: <20081103122512.06063fc9@mailhost.serverengines.com> <20081103193641.GA12552@kroah.com> <490F5667.3080904@garzik.org> <20081103201930.GB13299@kroah.com> <490F6234.4060805@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Subbu Seetharaman <subbus@serverengines.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:40112 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754135AbYKCUvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 15:51:04 -0500
Content-Disposition: inline
In-Reply-To: <490F6234.4060805@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 03:42:28PM -0500, Jeff Garzik wrote:
> Greg KH wrote:
>> On Mon, Nov 03, 2008 at 02:52:07PM -0500, Jeff Garzik wrote:
>>> Greg KH wrote:
>>>> On Mon, Nov 03, 2008 at 04:25:12AM -0800, Subbu Seetharaman wrote:
>>>>> If we could get more specific feedback about the areas that require
>>>>> cleanup, we can take care of them quickly.  Since the last posting, we 
>>>>> have brought up the driver in a PPC system
>>>>> and fixed some endianness issues.  As soon as I have some specific
>>>>> feedback, we can update the driver with these fixes as well.
>>>>>
>>>>> Please let me know as soon as the driver is in the staging area.
>>>> Does someone have a pointer to the driver, so that we can see what is
>>>> needed to be done?
>>> It was in my email :)  Repeating,
>>>
>>> The 'benet' branch of
>>> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
>>>
>>> It should be suitable for pulling directly into staging.
>> Hm, call me extreemly stupid, but I don't see anything in that branch
>> for this driver.
>> Here's what I did:
>>   git fetch 
>> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git benet 
>> master:jeff
>>   git checkout jeff
>> Even looking around at this tree with 'gitk --all' I don't see anything.
>> So what did I do wrong here?
>
> Well, the commit has been there long enough to mirror out, and show up on 
> the web interface:
>
> http://git.kernel.org/?p=linux/kernel/git/jgarzik/netdev-2.6.git;a=shortlog;h=benet
>
> therefore I am guessing there is some git user error here... but I could 
> not say what, since I am unfamiliar with your style of git invocation.
>
> I would recommend creating a new branch, or switching to an existing one, 
> and then pulling into it.  Pulling from a branch always works in my 
> experience, and that's what I've been doing since git was first written.
>
> URL=git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
> git checkout -b tmp master
> git pull $URL benet

Ok, that worked just fine, sorry for the noise, I was trying to be
"nice" and not use 'git pull' and use 'git fetch' like I thought I was
supposed to be doing :)

I can take it from here...

greg k-h
