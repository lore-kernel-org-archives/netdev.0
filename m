From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 0/3 2.5] e100 - driver update
Date: Fri, 17 Sep 2004 02:53:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170203520.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1 Changed error reporting strategy to use pci_device_name 
  for errors to be logged prior to registering the net device 
  with the kernel.
2 Use NET_IP_ALIGN to set rx data buffer address alignment. 
  NET_IP_ALIGN is defined to be appropriate for the processor 
  architecture for which the driver is compiled.
3 Driver version number update
