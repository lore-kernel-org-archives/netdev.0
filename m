From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Tue, 1 Apr 2003 11:13:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D314@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Jason Lunz <lunz@falooley.org>, Jeff Garzik <jgarzik@pobox.com>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
content-class: urn:content-classes:message
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>  Also still some concern by having the watchdog kicked in e1000_intr 
>  wouldn't e1000_clean feel better? 

e1000_intr feels better to me in keeping the clean-up work separate from
managing link status change (hopefully an infrequent event :).  Do you
see any problems?
 
>  It would also be interesting to see what happens if we 
> remove the flush when enable interrupts in e1000_clean?

Ya, that read hurts, which was part of the motivation to get rid of the
disable/enables altogether.  

>  I've tested the patch that removes some of the PCI-accesses. 
> I think I sent  you some version of it. Anyway it seems to 
> have some effects. If Jason has 
>  time we will get some numbers from his instrument/setup.

Ok, let's see.

-scott
