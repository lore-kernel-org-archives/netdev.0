From: kuznet@ms2.inr.ac.ru
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 1 Oct 2002 20:41:48 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210011641.UAA20171@sex.inr.ac.ru>
References: <3D99CA6D.5020808@nortelnetworks.com>
Mime-Version: 1.0
Cc: hadi@cyberus.CA, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: cfriesen@nortelnetworks.com (Chris Friesen)
In-Reply-To: <3D99CA6D.5020808@nortelnetworks.com> from "Chris Friesen" at Oct 1, 2 12:16:45 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Hmm...so even with IP_RECVERR I may not be notified if the packet is 
> dropped?

Do you not jest occasionally? :-) "Even" sounds interesting, because
this kind of errors cannot be reported _principially_ without IP_RECVERR,
providing asynchronous error reporting.

Packet can be dropped, damaged _after_ they are successfully queued
to the device. And this need not to be emphasized in documentation
on IP_RECVERR, except for a section "FUTURE DEVELOPMENT".


> either a) got out onto the wire, or b) my app got an error message back 
> explaining why the message didn't get onto the wire so that it can 
> decide how to proceed.

Then use IP_RECVERR. It reports all the errors which are detectable.

Alexey
