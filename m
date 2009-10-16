From: <Narendra_K@Dell.com>
Subject: RE: PATCH: Network Device Naming mechanism and policy
Date: Fri, 16 Oct 2009 19:32:50 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091013150839.GD32107@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com> <20091013173638.GE1119@ldl.fc.hp.com> <20091016003245.GD29672@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<Matt_Domsch@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Charles_Rose@Dell.com>
To: <dannf@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:59681 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbZJPOFW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 10:05:22 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20091016003245.GD29672@ldl.fc.hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>On Tue, Oct 13, 2009 at 11:36:38AM -0600, dann frazier wrote:
>> Right - so any reason this couldn't be implemented completely in 
>> userspace by having udev manipulate plain text files under say 
>> /etc/udev/net/?
>> 
>> I do agree that it would be nice for admins/installers to tweak/use 
>> nic names in a similar way to storage names (udev rules), 
>and it might 
>> let us take advantage of a lot of the existing udev code.
>
>Is there interest in this approach?
> - modify udev to manage network devices names as regular (non-device)
>   files (stored in /etc/udev, /dev/netdev, or wherever)

Yes. Would you elaborate little more on "modify udev to manage network
devices as regular files". Does it mean some custom rules which will
generate a regular file under, say, /dev/netdev/ or extend udev itself ?
And how would the regular file look like in terms of holding ifindex of
the interface, which can be passed to libnetdevname.


> - use the existing udev rules to manage symlinks to these files
> - point libnetdevname at these text files for its name resolution
>
>I've started prototyping this, and it certainly looks possible 
>w/o any kernel changes. However, I could probably use some 
>advice from a udev person to do a proper implementation.

With regards,
Narendra K  
