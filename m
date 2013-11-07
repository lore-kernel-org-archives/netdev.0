From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: xen-netback stable backport requests
Date: Thu, 7 Nov 2013 12:15:30 +0000
Message-ID: <1383826530.32399.13.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xen-devel <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

279f438e36c0 "xen-netback: Don't destroy the netdev until the vif is
shut down" has hit stable but unfortunately is causing regressions. 

This should be fixed by dc62ccaccfb1 "xen-netback: transition to CLOSED
when removing a VIF" which depends on ea732dff5cfa "xen-netback: Handle
backend state transitions in a more robust way".

Please could you queue hose two for stable.

Thanks,
Ian.
