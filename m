From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device sysfs entries
Date: Wed, 22 Oct 2008 15:54:23 -0700
Message-ID: <m11vy8jl5s.fsf@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<m1d4hso0ym.fsf@frodo.ebiederm.org> <20081022203045.GA4633@us.ibm.com>
	<m18wsgmji0.fsf@frodo.ebiederm.org> <20081022145507.2d1ea86c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev <netdev@vger.kernel.org>,
	Dave Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35711 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbYJVXEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 19:04:33 -0400
In-Reply-To: <20081022145507.2d1ea86c@extreme> (Stephen Hemminger's message of
	"Wed, 22 Oct 2008 14:55:07 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

>> The well-known user space tools don't use /sys at all.  Modern
>> network tools use rtnetlink (ip) old network tools use /proc/net.
>> 
>> Very few things actually use /sys and for those things lo@1 or
>> eth0@1 are completely useless except for implementing a FUSE
>> mock up of sysfs.  But you don't need anything in sysfs to do
>> that as all of the interesting information is available through
>> /proc/net or rtnetlink.
>
> Lots of scripts are starting use /sys for things. It is easier to
> parse /sys/class/net than the output of ifconfig or ip 

Yes.  So we need the correct values in /sys/class/net.

Which is why sysfs and network namespaces do not coexist currently.

Which is why I recommend only placing devices in the initial network
namespace in sysfs for the short term.

Which is why we need to get all of the details correct when we
handle multiple network namespaces and sysfs.

I should have something working and should be sending patches out
shortly.  Cleaning up sysfs and the device model enough so the changes
are not spooky is a long hard road unfortunately.

Eric
