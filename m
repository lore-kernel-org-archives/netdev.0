From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 20:14:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DAB0982.C0C6E36F@isg.de>
References: <Pine.GSO.4.30.0210140918170.26803-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, david-b@pacbell.net
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal,

> - NOTPRESENT makes sense more from a NMS pov where a hotplug device has
> been removed and SNMP finds that the device is no longer there. This
> can be done without any state from the kernel being exposed.

I want to forward this question mainly to the USB people. David, as you
are familiar with this thread, how does an USB  driver react when an
ethernet device is configured, running and then disconnected from the
USB port? From RFC2863, I'd expect the devicename ethx not to be removed
at least until it is ifconfigured down, but change from UP to NOTPRESENT
until reconnection. So it would be useful to have this state inside the
kernel.

> - UNKNOWN is when the NMS cant find the state of the device - maybe when
> they cant reach us. Again we dont need to expose this from the kernel and
> if it is not useful in the kernel perhaps should be deleted.

We have two different views here: For an external NMS, it makes perfect
sense to change devices of a host from whatever to UNKWOWN if the host
becomes unreachable. For the host itself, UNKNOWN can also be a driver
that does not know about link state detection.

I opt against removal of these states.

Cheers, Stefan
