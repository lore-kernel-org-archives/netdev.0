From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2] iproute2: generalize VXLAN forwarding tables
Date: Fri, 26 Apr 2013 13:08:17 -0700
Message-ID: <20130426130817.216bf46b@nehalam.linuxnetplumber.net>
References: <1902752B0C92F943AB7EA9EE13E2DEEC0DE5332594@HQ1-EXCH02.corp.brocade.com>
	<20130329085845.76c8b1e9@nehalam.linuxnetplumber.net>
	<OF46B0FF88.56F246DA-ON85257B59.004C2332-85257B59.004D92F4@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:64659 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856Ab3DZUIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 16:08:24 -0400
Received: by mail-da0-f52.google.com with SMTP id j17so2079291dan.11
        for <netdev@vger.kernel.org>; Fri, 26 Apr 2013 13:08:24 -0700 (PDT)
In-Reply-To: <OF46B0FF88.56F246DA-ON85257B59.004C2332-85257B59.004D92F4@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Apr 2013 10:07:17 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

> Stephen,
>         I assume you mean below that you're waiting for net-next changes 
> to
> be merged in Linus' tree for your build, but to be honest I'm not sure how 
> I can
> tell if this has happened or not. Do you do announcements for opening up
> 3.10 iproute2, or should I be watching a particular Linus git tree for the 
> include
> file changes?
>         I'd guess this is open again by now, and if so, I can merge and 
> resubmit,
> but I'd like to know for the future how I should time iproute2 
> submissions, so that
> you have the needed include file changes before I submit. Or, if you're 
> doing
> announcements, I can tweak my mail filters to make sure I see them.
>         Sorry if this is a newbie question or is covered in a FAQ 
> somewhere--
> it just never came up for me before.
>                                                 thanks,
>                                                         +-DLS

Up until now, I have mostly been lazy and only one branch of iproute2.
The master corresponds to the current Linus kernel headers and features.
Then I would collect patches during the merge window of the next release.
This is because the number of new features going into iproute2 was limited to 1 or 2
per release. But the speed is accelerating.

For next-release, I will split this into
  master == davem net == linus
  net-next == davem net-next
Which will mean more work for me and submitters (getting right branch), but
will make sure stuff doesn't get held out for so long.


Not changing right now, but will start after 3.10
