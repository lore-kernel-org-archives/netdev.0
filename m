From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND] benet: BladeEngine 10Gb NIC driver
Date: Mon, 03 Nov 2008 15:42:28 -0500
Message-ID: <490F6234.4060805@garzik.org>
References: <20081103122512.06063fc9@mailhost.serverengines.com> <20081103193641.GA12552@kroah.com> <490F5667.3080904@garzik.org> <20081103201930.GB13299@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Subbu Seetharaman <subbus@serverengines.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60620 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174AbYKCUmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 15:42:33 -0500
In-Reply-To: <20081103201930.GB13299@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH wrote:
> On Mon, Nov 03, 2008 at 02:52:07PM -0500, Jeff Garzik wrote:
>> Greg KH wrote:
>>> On Mon, Nov 03, 2008 at 04:25:12AM -0800, Subbu Seetharaman wrote:
>>>> If we could get more specific feedback about the areas that require
>>>> cleanup, we can take care of them quickly.  
>>>> Since the last posting, we have brought up the driver in a PPC system
>>>> and fixed some endianness issues.  As soon as I have some specific
>>>> feedback, we can update the driver with these fixes as well.
>>>>
>>>> Please let me know as soon as the driver is in the staging area.
>>> Does someone have a pointer to the driver, so that we can see what is
>>> needed to be done?
>> It was in my email :)  Repeating,
>>
>> The 'benet' branch of
>> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
>>
>> It should be suitable for pulling directly into staging.
> 
> Hm, call me extreemly stupid, but I don't see anything in that branch
> for this driver.
> 
> Here's what I did:
>   git fetch git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git benet master:jeff
>   git checkout jeff
> 
> Even looking around at this tree with 'gitk --all' I don't see anything.
> So what did I do wrong here?

Well, the commit has been there long enough to mirror out, and show up 
on the web interface:

http://git.kernel.org/?p=linux/kernel/git/jgarzik/netdev-2.6.git;a=shortlog;h=benet

therefore I am guessing there is some git user error here... but I could 
not say what, since I am unfamiliar with your style of git invocation.

I would recommend creating a new branch, or switching to an existing 
one, and then pulling into it.  Pulling from a branch always works in my 
experience, and that's what I've been doing since git was first written.

URL=git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
git checkout -b tmp master
git pull $URL benet

Regards,

	Jeff



