From: Lincoln Dale <ltd@cisco.com>
Subject: Re: TOE brain dump
Date: Wed, 06 Aug 2003 18:20:06 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030806181359.02bf9570@mira-sjcm-3.cisco.com>
References: <3F2CAE61.7070401@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org, Werner Almesberger <werner@almesberger.net>,
   Nivedita Singhvi <niv@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andre Hedrick <andre@linux-ide.org>
In-Reply-To: <Pine.LNX.4.10.10308060009130.25045-100000@master.linux-ide
 .org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 05:12 PM 6/08/2003, Andre Hedrick wrote:
>Do be sure to check that your data payload is correct.
>Everyone knows that a router/gateway/switch with a sticky bit in its
>memory will recompute the net crc16 checksum insure it pass the to the nic
>regardless.  It is amazing how much data can be corrupted by a network
>environment via all the NFS/NBD/etc wantabie storage products out there.

Andre, you are wrong.

firstly, do you REALLY think that most router(s)/switch(es) out there 
recompute IP checksums because they did a IP TTL decrement when routing an 
IP packet or NAT IP addresses?

no, they don't.  just like netfilter or router-on-linux is smart enough to 
be able to re-code an IP checksum by unmasking and re-masking the old/new 
values in a header, so does the most router vendor's code.

secondly, why would a router or switch even be touching the data at layer-4 
(TCP), let alone recalculating a CRC?

i know you really like your "we do ERL 2 in iSCSI" pitch, but lets stick to 
facts here eh?


cheers,

lincoln.
