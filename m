From: Paul Jakma <paul@clubi.ie>
Subject: Re: [patch 4/10] s390: network driver.
Date: Sun, 21 Nov 2004 08:16:34 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0411210806340.10262@hibernia.jakma.org>
References: <OF88EC0E9F.DE8FC278-ONC1256F4A.0038D5C0-C1256F4A.00398E11@de.ibm.com>
 <4196B4E9.40502@pobox.com> <Pine.LNX.4.61.0411150735070.10262@hibernia.jakma.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Thomas Spatzier <thomas.spatzier@de.ibm.com>,
	linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261918AbUKUIQ5@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <Pine.LNX.4.61.0411150735070.10262@hibernia.jakma.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Nov 2004, Paul Jakma wrote:

> non-raw/header-included sockets, eg BGP tcp sockets, a user like 
> GNU Zebra / Quagga would much prefer packets to be dropped.

Ur... not for TCP.. obviously.

Anyway, is there any advice on how applications that use a single 
socket for raw/udp should deal with this new behaviour? All of the 
link-orientated routing protocol daemons in Quagga/GNU Zebra are 
going to break on Linux with this new behaviour.

Should such applications be changed to open a seperate socket per 
interface? Or could we have a SO_DROP_DONT_QUEUE sockopt to allow a 
privileged application to retain the previous behaviour, or some way 
to flush the queue for a socket?

Using a socket per interface wont address problem of sending quite 
stale packets when a link comes back after a long time down, AUI. 
(not a huge problem - but not nice).

Jeff???

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
Be incomprehensible.  If they can't understand, they can't disagree.
