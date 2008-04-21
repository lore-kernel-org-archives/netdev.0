From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Mon, 21 Apr 2008 15:38:48 +0300
Message-ID: <480C8AD8.9050609@teltonika.lt>
References: <20080414213238.GB28833@kroah.com> <200804171632.12972.oliver@neukum.org> <4808BBC5.5070800@teltonika.lt> <200804211345.12850.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:60547 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756347AbYDUMjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 08:39:44 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JnvJ5-0001mw-Mh
	for netdev@vger.kernel.org; Mon, 21 Apr 2008 12:39:39 +0000
Received: from 82-135-208-232.static.zebra.lt ([82.135.208.232])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 12:39:39 +0000
Received: from paulius.zaleckas by 82-135-208-232.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 12:39:39 +0000
In-Reply-To: <200804211345.12850.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum wrote:
> Am Freitag, 18. April 2008 17:18:29 schrieb Paulius Zaleckas:
>> Oliver Neukum wrote:
>>> Hi,
>>>
>>> can you test this one as well. The method used to determine whether
>>> a device is asleep is racy. This introduces a private test.
>>>
>>> 	Regards
>>> 		Oliver
>> By setting level "auto" it didn't suspend...
>> When I tried to set "suspend" to the level I got crash:
> 
> Does this fix it?

Looks like it fixed this crash.
I don't see anything on dmesg and /var/log/messages when I do
echo "suspend" > power/level, but that is IMO another story.

Paulius

