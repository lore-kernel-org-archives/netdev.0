From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 09:38:01 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210140918170.26803-100000@shell.cyberus.ca>
References: <3DAABBAE.79E22EB6@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DAABBAE.79E22EB6@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



If you think about it NOTPRESENT was always there even without these
changes but was never exposed. PRESENT will always somehow get mapped
to IFF_RUNNING (0/1).
- NOTPRESENT makes sense more from a NMS pov where a hotplug device has
been removed and SNMP finds that the device is no longer there. This
can be done without any state from the kernel being exposed.
- UNKNOWN is when the NMS cant find the state of the device - maybe when
they cant reach us. Again we dont need to expose this from the kernel and
if it is not useful in the kernel perhaps should be deleted.

The remainder seem to make more sense to me.

thoughts?

cheers,
jamal
