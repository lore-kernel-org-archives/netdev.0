From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device sysfs entries
Date: Wed, 22 Oct 2008 14:08:26 -0700
Message-ID: <m17i80l4mt.fsf@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<20081022201601.GC24959@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	netdev <netdev@vger.kernel.org>,
	Dave Miller <davem@davemloft.net>,
	Al Viro <viro@ftp.linux.org.uk>,
	Serge Hallyn <serue@us.ibm.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36540 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753678AbYJVVOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 17:14:34 -0400
In-Reply-To: <20081022201601.GC24959@suse.de> (Greg KH's message of "Wed, 22
	Oct 2008 13:16:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <gregkh@suse.de> writes:

> On Wed, Oct 22, 2008 at 05:21:44PM +0200, Benjamin Thery wrote:
>> Network devices from sub-network namespaces appear in sysfs
>> with a name that looks like this: device_name@netns_id
>> eg: lo@3, eth0@4e
>
> How does the default udev rules as shipped by most distros handle the
> renaming of the network device if the MAC address is duplicated like it
> will be for these eth devices?

The mac address is not duplicated.

Further devices like eth0@4e are completely unusable to the udev
rules in the initial network namespace because they can not talk
to or affect them.

As I read it Ben's ``solution'' puts entries in sysfs that are
completely unusable to udev.

Eric

