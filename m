From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Problems with e1000 in 2.4.23
Date: Sun, 30 Nov 2003 20:06:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDD09@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Ben Greear" <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Could the problem happen because I do the set-multi even if
> the NIC is down?  Is there enough locking in the 
> e1000_ethtool additions?

Change ETHTOOL_SETRXALL to work more like ETHTOOL_SRXCSUM, with the
check for netif_running and down/up or reset.

-scott
