From: Jeff Garzik <jgarzik@pobox.com>
Subject: netdev3 posted...
Date: Mon, 12 Jan 2004 20:58:45 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <400350D5.2060707@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040802030002030207090206"
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040802030002030207090206
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


With a couple fixes (another bad one in r8169) and a couple little 
things.  Changelog delta versus netdev2 attached.

The ppp header removal was Paul M's idea, but I took it farther, so it 
still needs ack'ing from him (as ppp maintainer).

Patch:
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.1-bk1-netdev3.patch.bz2

Full changelog:
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.1-bk1-netdev3.log

Broken-out patches:
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/broken-out/



--------------040802030002030207090206
Content-Type: text/plain;
 name="changelog.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changelog.txt"

ChangeSet@1.1510.3.6, 2004-01-12 19:41:02-05:00, ak@muc.de
  [PATCH] variable number of dummy devices
  
  Uses the new module_params that nobody else uses now.

ChangeSet@1.1510.15.54, 2004-01-12 17:27:00-05:00, jgarzik@redhat.com
  Eliminate ancient and unused include/linux/{if_pppvar,ppp}.h.
  
  Well, unused except for one silly constant in isdn_ppp.c.

ChangeSet@1.1510.6.21, 2004-01-12 17:21:23-05:00, akpm@osdl.org
  [PATCH] fix netpoll printk bug

ChangeSet@1.1510.9.18, 2004-01-12 17:19:54-05:00, romieu@fr.zoreil.com
  [netdrvr r8169] fix rx counter masking bug

ChangeSet@1.1510.15.53, 2004-01-11 01:19:14-05:00, viro@parcelfarce.linux.theplanet.co.uk
  Remove unused and invalid 'struct ppp' definition from if_pppvar.h.

ChangeSet@1.1510.10.3, 2004-01-11 01:09:34-05:00, viro@parcelfarce.linux.theplanet.co.uk
  [netdrvr forcedeth] kfree -> free_netdev

ChangeSet@1.1510.3.5, 2004-01-11 01:08:18-05:00, viro@parcelfarce.linux.theplanet.co.uk
  [NET] fix leak in sch_teql
  
  Also note the fact that we're calling functions that may block,
  while holding a local spinlock.


--------------040802030002030207090206--
