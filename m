From: Tejun Heo <htejun@gmail.com>
Subject: Re: patch sysfs-implement-sysfs-tagged-directory-support.patch added
 to gregkh-2.6 tree
Date: Fri, 30 Apr 2010 08:12:40 +0200
Message-ID: <4BDA74D8.9020503@gmail.com>
References: <12725729473590@kroah.org> <4BDA5A2D.6080904@kernel.org>	<20100430044522.GA29845@suse.de> <m1aaslbjh4.fsf@fess.ebiederm.org> <4BDA6C90.9010303@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>, bcrl@lhnet.ca, benjamin.thery@bull.net,
	cornelia.huck@de.ibm.com, eric.dumazet@gmail.com,
	kay.sievers@vrfy.org, netdev@vger.kernel.org, serue@us.ibm.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:43274 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758322Ab0D3RLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:11:13 -0400
Received: by bwz19 with SMTP id 19so266450bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 10:11:11 -0700 (PDT)
In-Reply-To: <4BDA6C90.9010303@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 04/30/2010 07:37 AM, Tejun Heo wrote:
>> Tejun I think for the code to make any sense to you I would need to rip
>> out out and/or rewrite the kobject layer, and possible the device
>> model code as well.
> 
> And yes, in the long run, please do that.

Let me add a little bit here just in case.

IIRC, the initial sysfs tag support wasn't too different from the
interface side but the implementation inside sysfs was very hacky, so
I complained on both accounts.  You did a wonderful job of
restructuing sysfs so that it basically behaves as a distributed file
system and exposing different subsets is not too hacky and doesn't
violate layering.  Your work there was admirable and much better than
what I had in mind.

I don't think the hooking part from NSes would be as major an overhaul
as you're suggesting above.  I haven't tried it so I can't tell with
certainty (again so no nack) but I just can't imagine it being that
difficult or major after all the things you've done in the area and
was hoping that you repost something which is more digestible soonish.

I'm sorry that I couldn't be more specific but I'm almost sure you'll
be able to come up with something better than what I can think of.
So, yeah, please,

* Add comments to the current implementation.  If for nothing else,
  for cases where you get sick of it for some time and other people
  have to work on it before you feel like coming back.

* While doing that, please add "FIXME: or TODO:" comments describing
  what would be a better direction in the long run.

Thanks.

-- 
tejun
