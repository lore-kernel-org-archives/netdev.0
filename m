From: Paul Chany <csanyipal@gmail.com>
Subject: Re: Bug#584238: linux-image-2.6.32-3-486: When using USB to Ethernet nework adapter later on get error: blocked for more than 120 seconds
Date: Wed, 09 Jun 2010 15:15:26 +0200
Message-ID: <87aar4e49d.fsf@debian-laptop.localdomain>
References: <20100602144551.2330.64473.reportbug@debian-laptop.localdomain>
	<1275521053.2870.70.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 584238@bugs.debian.org,
	Petko Manolov <petkan@users.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40377 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755962Ab0FINPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 09:15:37 -0400
Received: by fxm8 with SMTP id 8so3566538fxm.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 06:15:35 -0700 (PDT)
In-Reply-To: <1275521053.2870.70.camel@localhost> (Ben Hutchings's message of
	"Thu, 03 Jun 2010 00:24:13 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben@decadent.org.uk> writes:

> On Wed, 2010-06-02 at 16:45 +0200, Paul Chany wrote:
>> Package: linux-2.6
>> Version: 2.6.32-9
>> Severity: normal
>> Tags: squeeze
>> 
>> When using USB to Ethernet adapter later on get error on console:
>> 
>> [11531.988248] INOF: task khubd:618 blocked for more than 120 seconds.
>> [11531.988377] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>> message.
>> [11531.990656] INFO: task pegasus:1156 blocked for more than 120 seconds.
>> [11531.990722] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>> message.
>> 
>> After that I can't reconfigure anymore network, nor reboot the system with the command: 
>> sudo shutdown -t 1 -r now
>> because the system hangs forever.
>> 
>> It is not help if I unplug and plug in again the network adapter, it is not recognised by 
>> the kernel anymore.
>
> I'm forwarding this to the pegasus driver developers so they can comment
> on it.
>
> Debian kernel version 2.6.32-9 is closely based on stable kernel
> 2.6.32.9.

It seems that the developers dont' responds for this bugreport at all.
Is the pegasus kernel driver a dead project now?
There in their projectpage: http://pegasus2.sourceforge.net/
one can see that that pegasus is available
only for kernels 2.4 and 2.5 but not for 2.6, right?

In the meantime I can to reboot every hour or so because of this buggish
driver.

-- 
Regards,
Paul Chany
You can freely correct my English.
http://csanyi-pal.info
