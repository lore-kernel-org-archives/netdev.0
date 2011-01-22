From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback down
Date: Sat, 22 Jan 2011 00:17:09 -0800
Message-ID: <m1k4hxuzcq.fsf@fess.ebiederm.org>
References: <20101209.122033.183046393.davem@davemloft.net>
	<20101216132812.2d7fd885@nehalam> <m1mxo5tcx6.fsf@fess.ebiederm.org>
	<20101216.182656.226781473.davem@davemloft.net>
	<20110119191823.GC8442@midget.suse.cz> <20110119113817.0819ddf1@s6510>
	<20110119195632.GA27574@midget.suse.cz>
	<20110119120123.40974cbe@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, David Miller <davem@davemloft.net>,
	brian.haley@hp.com, netdev@vger.kernel.org, maheshkelkar@gmail.com,
	lorenzo@google.com, yoshfuji@linux-ipv6.org, stable@kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:39492 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222Ab1AVIRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jan 2011 03:17:22 -0500
In-Reply-To: <20110119120123.40974cbe@s6510> (Stephen Hemminger's message of
	"Wed, 19 Jan 2011 12:01:23 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Wed, 19 Jan 2011 20:56:32 +0100
> Jiri Bohac <jbohac@suse.cz> wrote:
>
>> On Wed, Jan 19, 2011 at 11:38:17AM -0800, Stephen Hemminger wrote:
>> > Jiri Bohac <jbohac@suse.cz> wrote:
>> > > I have the feeling that Eric's patch is the safest solution we
>> > > have so far:
>> > Eric's patch has other regressions, see the discussion.
>> 
>> What regression do you mean? I have read the whole discussion
>> thoroughly. You only say in one message that deleting ::1 would
>> propagate to routing daemons. And Eric correctly stated that
>> people couldn't hit this, because  deleting ::1 would break
>> things on its own.
>> 
>> Is there a real problem with Eric's fix?
>> 
>> Thanks,
>> 
>
> If address is assigned to loopback interface (other than ::1) then
> Eric's fix doesn't work.  It is common to use an additional address
> on the lo device when doing routing protocols.

Sigh.

I just got back to looking through the rest of my failures in 2.6.37 and
despite it looking like it worked when i tested it, your patch doesn't
actually work on my real work load that has broken.

At least your change that confirmed that the root problem is somewhere
in the routing.

Eric


