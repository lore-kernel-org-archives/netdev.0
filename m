From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: netdev->mem_start, etc
Date: Tue, 25 Nov 2003 09:50:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDCF9@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Is there any reason why these fields should be set for a PCI nic driver?

  netdev->mem_start
  netdev->mem_end
  netdev->base_addr

They seem to be vestigial.  

(I'm trying to prune a e100/e1000 dependency with a app that's matching
on these fields to figure out PCI device ID).

-scott
