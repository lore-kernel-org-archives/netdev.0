From: "Kevin Curtis" <kevin.curtis@farsite.co.uk>
Subject: RE: Update FarSync WAN driver in 2.6
Date: Fri, 19 Mar 2004 09:26:28 -0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7C078C66B7752B438B88E11E5E20E72E25CC84@general.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, <davem@redhat.com>, <Kevin.curtis4@btopenworld.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,
	the FarSync driver updates in the 2.4 and 2.6 Kernels is
becoming a little more critical.  Please can you make your best efforts
to incorporate it into the next release of each.


Kind Regards

Kevin Curtis
Linux Development
FarSite Communications Ltd
http://www.farsite.co.uk
tel:  +44 1256 330461
fax:  +44 1256 854931

-----Original Message-----
From: Kevin Curtis 
Sent: 12 March 2004 16:57
To: Kevin Curtis; 'Jeff Garzik'
Cc: 'netdev@oss.sgi.com'; 'davem@redhat.com'
Subject: RE: Update FarSync WAN driver in 2.6


Any progress on getting the farsync patches into the 2.4 and 2.6
Kernels?


Kevin

-----Original Message-----
From: Kevin Curtis 
Sent: 01 March 2004 13:56
To: Kevin Curtis; 'Jeff Garzik'
Cc: 'netdev@oss.sgi.com'; 'davem@redhat.com'
Subject: RE: Update FarSync WAN driver in 2.6


Here is the modified patch.
It installs against 2.6.4-pre1

Best get it in quick before net_device is given back to the hdlc layer
again :->


Kevin

-----Original Message-----
From: Kevin Curtis 
Sent: 01 March 2004 09:15
To: 'Jeff Garzik'; Kevin Curtis
Cc: netdev@oss.sgi.com; davem@redhat.com
Subject: RE: Update FarSync WAN driver in 2.6


Hi,
	looks as though the 2.6.4-pre1 patch has changed farsync.c,
which is probably why the patch will not apply.  I would re-work the
patch against this release.

	What is the status of the 2.4.x patch that I sent a while back?
I still need to make one more change to it.  I need to know if to resend
the whole patch, or a n additional patch with the change?


Kevin

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com] 
Sent: 29 February 2004 18:53
To: Kevin Curtis
Cc: netdev@oss.sgi.com; davem@redhat.com
Subject: Re: Update FarSync WAN driver in 2.6


hum...  Patch looks OK to appy, but does not apply against the latest 
2.6.x kernel.

Also, it is possible to split your patch into two pieces:  one patch 
with nothing but indentation/whitespace cleanups, and the other patch 
with functional changes?

	Jeff
