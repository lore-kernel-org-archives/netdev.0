From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: e100-3.0.0_dev8 "Minneapolis Moline" release
Date: Tue, 17 Jun 2003 19:48:02 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D977@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <linux-net-owner@vger.kernel.org>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
List-Id: netdev.vger.kernel.org

[Someone once suggested e100 as the first nominee into the driver hall
of shame.  I'd like to revoke that nomination with this rewrite of
e100].

    DON'T USE THIS DRIVER ON A PRODUCTION SYSTEM!

http://sf.net/projects/e1000, download e100-3.0.0_dev8 (tar file or
kernel patches).

Your help in testing would be greatly appreciated.  There are many 8255x
devices supported by e100, so hopefully we'll get good coverage from the
community.

Also, any feedback on the code correctness, maintainability, credits,
etc. would help.  We're really motivated in getting this driver as
perfect as possible.  It's about 2200 lines, down from about 9000
before, so hopefully that helps.  :)

It does NAPI, ethtool (probably the most ethtool-compliant driver out
there), and MII ioctl.  The only module parameter is "debug", used to
set the initial message level.  All other driver settings must be done
via ethtool.

     DON'T USE THIS DRIVER ON A PRODUCTION SYSTEM!

Thanks to Jeff and Arjan for great feedback and encouragement.

-scott
