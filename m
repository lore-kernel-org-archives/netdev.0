From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: bonding sysfs output
Date: Tue, 27 Nov 2007 10:56:43 +0100
Message-ID: <87prxwnh9g.fsf@tac.ki.iif.hu>
References: <87tznafjeu.fsf@szonett.ki.iif.hu>
	<20071125205150.4e49915f.akpm@linux-foundation.org>
	<87lk8lflzf.fsf@szonett.ki.iif.hu>
	<20071127004445.a046f791.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:58265 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753480AbXK0J4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 04:56:49 -0500
In-Reply-To: <20071127004445.a046f791.akpm@linux-foundation.org> (Andrew
	Morton's message of "Tue, 27 Nov 2007 00:44:45 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Mon, 26 Nov 2007 09:29:40 +0100 Wagner Ferenc <wferi@niif.hu> wrote:
>
>> Trailing NULs are present in each file under /sys/class/net/*/bonding
>> and also in /sys/class/net/bonding_masters.  That is, in every file
>> provided by drivers/net/bonding/bond_sysfs.c.  Most of the patch is
>> concerned with this.
>> 
>> Closely related is the presence of trailing spaces in multivalue
>> files.  There are three such files, one of them has the trailing space
>> removed.  This patch removes it from the other two.  During this it
>> also renames one function argument 'buffer' to 'buf', for consistency.
>> 
>> On the policy side: some files are not applicable to some types of
>> bonds, and return a single linefeed in that case.  Except for one
>> single case, which returns 'NA\n'.  The patch changes these cases into
>> emtpy files.
>> 
>> If these are worthy changes, I'm absolutely willing to split up the
>> patch into three parts as the above.
>
> Well that would be good if poss, thanks.

Will do.  Not exactly a simple thing, as the changes collide.

> But fixing bugs is way more important than niceties of patch presentation
> however I wasn't prepared to fix the rejects which that patch is hitting in
> the considerably-changed bonding_show_ad_partner_mac().  Please:

Yes, the patch was against 2.6.23.8.  Forgot to mention. :(

> - raise patches against the latest Linus tree
> (ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snapshots/)

I thought it was better to change to git.  Isn't it so?
SubmittingPatches has nothing to say about that...
Can I find collected best practices somewhere?  Which tree, which
branch, how/when to rebase, format-patch, etc...

(If given no further instructions, I'll try my best and you can
reflect on the result.  I mean, the above questions are not blocking
me, feel free not to answer.)

> - cc netdev@vger.kernel.org on networking-related matters
>
> - Include a Signed-off-by: as per Documentation/SubmittingPatches
>
> - Try to ensure that the full explanation (such as you have above) is
> covered in the changelog text.

Ok.
-- 
Thanks for your time,
Feri.
