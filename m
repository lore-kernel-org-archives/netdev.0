From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Limit skb to be less than 64K with TSO
Date: Wed, 23 Jul 2003 11:44:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E01022291F4@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Alan Shih" <alan@storlinksemi.com>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I am writing driver + smart NIC's firmware.  The smart NIC 
> has limited memory. It can do checksum and TSO but with 32K max.

Do we need a netdev->tso_max so the driver can advertise the maximum TSO
send support by h/w?
