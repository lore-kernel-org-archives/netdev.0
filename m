From: kuznet@ms2.inr.ac.ru
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 1 Oct 2002 18:40:12 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210011440.SAA19721@sex.inr.ac.ru>
References: <3D99B07B.7050901@nortelnetworks.com>
Mime-Version: 1.0
Cc: hadi@cyberus.CA, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: cfriesen@nortelnetworks.com (Chris Friesen)
In-Reply-To: <3D99B07B.7050901@nortelnetworks.com> from "Chris Friesen" at Oct 1, 2 10:26:03 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> If I'm looping on a sendto() with a blocking socket, I would expect the 
> syscall to block until the packet has been handed off to the device 
> driver.  This may mean blocking until local congestion backs off.

Feel free to implement. :-)


> The way we do it now means that we can chew up massive amounts of cpu 
> creating packets in userspace and throwing them away in the kernel, with 
> no way of knowing from userspace that it is happening.

What? If your applications is enough clever to handle ENOBUFS right,
set IP_RECVERR and live in peace.

Alexey
