From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: e1000 lockup with port io type reset
Date: Fri, 27 Jun 2003 08:57:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107DA2C@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Zwane Mwaikambo" <zwane@linuxpower.ca>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The following card causes a hard lockup when we do a controller 
> reset using port io instead of mmio. Switching to mmio 
> controller reset causes it to function as expected

Please send me a description of system (model, kernel, DMI decode, etc),
plus dumps from lspci -vv -xxx and ethtool -d ethX.  If we can repro
this, we should be able to get a bus trace.

-scott
