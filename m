From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [2.4] e1000 leaking pci mappings on rx errors?
Date: Mon, 12 Jan 2004 09:43:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDDC5@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "cramerj" <cramerj@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-Class: urn:content-classes:message
To: <olof@austin.ibm.com>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> We have a machine here (running a RHEL 2.4.21-based kernel), 
> that started showing leakage of PCI mappings when the driver 
> was upgraded from 5.1.11 to 5.2.20.

Olof, please try 5.1.13 and 5.2.16 from sf.net/projects/e1000 to help
narrow the diff.  I'm not seeing anything obvious in the diff between
5.1.11 and 5.2.20 that would explain this.

-scott
