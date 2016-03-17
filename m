From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH V3 net-next] ixgbe: Avoid unaligned access in ixgbe_atr()
 for LLC packets
Date: Wed, 16 Mar 2016 18:31:42 -0700
Message-ID: <CAKgT0Uds_==AZrM-5JsoCDYDQas3JVcXK6Z5B7-PYG+b=wyBnQ@mail.gmail.com>
References: <20160314194716.GM5084@oracle.com>
	<1458169132.2878.25.camel@intel.com>
	<20160316230157.GK21307@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	shannon nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35128 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444AbcCQBbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 21:31:43 -0400
Received: by mail-ig0-f175.google.com with SMTP id vf5so131577434igb.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 18:31:42 -0700 (PDT)
In-Reply-To: <20160316230157.GK21307@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 4:01 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (03/16/16 15:58), Jeff Kirsher wrote:
>>
>> This does not apply since Alex Duyck beat you to the fix.  Here is the
>> patch he submitted on 3/15 which corrects the issue.  So I am dropping
>> your patch from the queue.
>>
>
> That's weird because Alexander was reviewing my fix on the various
> lists yesterday, so he could have just told me about this.
>
> But, whatever.

Sowmini,

Just for the record I didn't submit it on March 15 I submitted it on
January 26th as per the log in patchwork,
http://patchwork.ozlabs.org/patch/573058/.

Sorry I didn't realize the patch was not against the next-queue.  Back
when I made that fix I was focused on the IPv6 portion of it so that
piece of it had slipped my mind.  If it is any consolation at least my
patch is 7+ weeks ahead in the queue so hopefully the fix will make it
into net-next as soon as the merge window opens.

- Alex
