From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Problems with e1000 in 2.4.23
Date: Sun, 30 Nov 2003 18:19:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDD05@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Ben Greear" <greearb@candelatech.com>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Attached is an oops that did not hang the machine.

Re: e1000_dump.txt: I'm 99% sure this shows dev_close being called
without a matching dev_open, or a dev_close after failed dev_open.
e1000 doesn't guard against that (and shouldn't), so we need to figure
out how you're getting here and fix that.  What's above e1000?  Are you
using bonding or pktgen or ?

-scott
