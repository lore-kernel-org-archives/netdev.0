From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Tue, 09 Apr 2002 13:28:37 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CB2D065.A3DA60BB@isg.de>
References: <Pine.GSO.4.30.0204072343250.12041-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Richardson <mcr@sandelman.ottawa.on.ca>, netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
List-Id: netdev.vger.kernel.org

Hi Jamal,

> [discussion whether IFOP_DOWN_LOWERLAYER should send netlink messages]
> 
> I think they should be accessible; whether you send netlink
> advertisements everytime there is some state transition is the question.

they should. For a routing daemon it is interesting to be notified when
interfaces becomes capable or incapable of handling packets, independant
of the reason. As long as we abstract virtual or subinterfaces as normal
interfaces to the upper layers (which is IMHO the correct decision),
IFOP_DOWN_LOWERLAYER must trigger a notification.

Stefan
