From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: link state notification for 2.5.41
Date: Sat, 12 Oct 2002 09:09:12 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210120857550.23509-100000@shell.cyberus.ca>
References: <3DA76407.F16521F4@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>, <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DA76407.F16521F4@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



You didnt do the most important thing we discussed:
A global list of devices with work - not to pollute the net_device
structure. This way it is more manageable. Imagine 10K devices (with
software devices on top of physical devices this is not unusual).
Devices register work to be done on this queue. If they register multiple
times, then only the latest event if different from whats already on the
queue gets propagated via netlink (this part you do correctly).

BTW, did you ping the USB people on notPresent? At least one of them i
think participated in that discussion.

cheers,
jamal
