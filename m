From: "Leech, Christopher" <christopher.leech@intel.com>
Subject: RE: e1000 -> 82540EM on linux 2.6.0-test[45] very slow in one direction
Date: Fri, 3 Oct 2003 11:27:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E3A930D59AFC3345AEBA35189102A8A6193289@orsmsx404.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <ookhoi@humilis.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Btw, I had to compile the e1000 driver as a module. Compiled in it
> doesn't work, as is stated on the intel support page:

> This is not clear from the kernel config help. A patch against
> 2.6.0-test6 is attached (I don't know how to only give n/m as an
> option).

This patch is not necessary or desired.  The version of e1000 that ships
with the kernel source should work fine statically linked, and the
comment on the Intel support web page applies to the separate download
of the e1000 source.  If you download the driver source from Intel and
do the work to add it into a kernel source tree yourself, Intel customer
support may not help you when you have problems.

If you are having problems compiling in the version of e1000 that ships
with the kernel, please report it on netdev and we'll try and help.
 
> Btw2, can somebody please explain what the option E1000_NAPI does?

NAPI is a network driver polling mode interface.  It enables a form of
software managed interrupt moderation, and may result in better
performance under some traffic patterns (specifically sustained high
packet rate reception).

-- Chris
