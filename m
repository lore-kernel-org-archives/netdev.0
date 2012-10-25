From: Aleksander Morgado <aleksander@lanedo.com>
Subject: Re: qmi-wwan bug
Date: Thu, 25 Oct 2012 12:36:26 +0200
Message-ID: <5089162A.9090608@lanedo.com>
References: <5088385C.1090304@accelecon.com> <943c3dc1-8bc7-4678-a6fd-adc5051f331c@email.android.com> <50886B75.9080408@accelecon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	netdev <netdev@vger.kernel.org>
To: "Shawn J. Goff" <shawn.goff@accelecon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanedo.com ([85.214.136.179]:49278 "EHLO lanedo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758937Ab2JYKoN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 06:44:13 -0400
In-Reply-To: <50886B75.9080408@accelecon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>> When it is in failure, if I try to ping an address, the system sends
>>> out
>>> several an ARP requests but gets no response. To get the device to
>>> respond again, I have to administratively set the wwan interface down,
>>> then up, use libqmi to get the connection going again, then dhcp to get
>>>
>>> an address.
>> Which sounds like the connection died. Does QMI work at this point, or
>> is that dead too?
> 
> Looks like qmi works. I can do --nas-get-signal-strength and it gives me
> good numbers. --wds-get-packet-service-status returns "Connection
> status: '2'"

Out of topic...  I just fixed qmicli so that it prints the enum nickname
string instead of the integer value.

-- 
Aleksander
