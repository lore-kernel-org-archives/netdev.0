From: "Avniwb" <avniwb@future.futsoft.com>
Subject: RE: injecting packets
Date: Tue, 16 Apr 2002 13:45:29 +0530
Sender: linux-net-owner@vger.kernel.org
Message-ID: <000801c1e51e$df6b1100$0307040a@future.futsoft.com>
References: <Pine.LNX.4.30.0204161203210.15280-100000@brahmi.ee.iitb.ac.in>
Reply-To: <avniwb@future.futsoft.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: "'Vasu'" <vasu@ee.iitb.ac.in>,
	"'linux-net'" <linux-net@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.30.0204161203210.15280-100000@brahmi.ee.iitb.ac.in>
List-Id: netdev.vger.kernel.org

try dev_queue_xmit in dev.c.

or u can see chapter 13 of this...

http://www.cs.unh.edu/cnrg/gherrin/linux-net.html

ENJOY!!!
Avni :-)


-----Original Message-----
From: linux-net-owner@vger.kernel.org
[mailto:linux-net-owner@vger.kernel.org]On Behalf Of Vasu
Sent: Tuesday, 16 April 2002 12:10 PM
To: linux-net
Subject: injecting packets



Hi.

I am trying to write a module that takes Ethernet packets from the user
domain, and injects it into the proper place ( which I think is the
sk_buffers ), so that to the IP, TCP layer, the packets look as if coming
from the Ethernet device. Can someone please suggest me which files to
look into, and which structs to handle, for getting this done. Also, I
want to do the reverse task, i.e. take some particular packets ( say which
come from a specific port ) from sk_buffers and send it to user space.

Please assume that this silly looking Rx/Tx has some importance :)

Regards.

Vasu.
III yr EE student.


-
To unsubscribe from this list: send the line "unsubscribe linux-net" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

***************************************************************************
This message is proprietary to Future Software Limited (FSL) 
and is intended solely for the use of the individual to whom it
is addressed. It may contain  privileged or confidential information 
and should not be circulated or used for any purpose other than for 
what it is intended. 

If you have received this message in error, please notify the
originator immediately. If you are not the intended recipient,
you are notified that you are strictly prohibited from using,
copying, altering, or disclosing the contents of this message. 
FSL accepts no responsibility for loss or damage arising from 
the use of the information transmitted by this email including
damage from virus.
***************************************************************************
