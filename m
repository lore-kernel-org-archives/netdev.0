From: Venkata Jagana <jagana@us.ibm.com>
Subject: [ANNOUNCE] Linux DHCPv6 release available for download
Date: Thu, 30 Jan 2003 17:05:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF3F47AF4C.84072AF6-ON88256CBF.00044306@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The DHCPv6 (DHCP for IPv6) code (ver 0.1) is now available for
download at SourceForge:

     http://www.sourceforge.net/projects/dhcpv6

Linux DHCPv6 project is created to provide IETF standard conformant
DHCPv6 protocol implementation for Linux.

The current version of the code provides 'partial' Client/Server support
for
address assignment. Additional messages support is currently under
development.

The current status of the project, at a high level, is provided below but
for further details, please visit the DHCPv6 project page at SourceForge.


On behalf of DHCPv6 team,

Regards,
Venkat

----------------------------------------------------------------
Venkata R Jagana
IBM Linux Technology Center
Beaverton
jagana@us.ibm.com
----------------------------------------------------------------


Current Status:

  Features implemented and validated

    IPv6 address Assignment

      - Server configuration file support
      - Server lease file support for saving all the client's IPv6 address
binding info
      - Client IPv6 address assignment and temporary IPv6 address
assignment support on the same link
      - Supported Options: Rapid commit, Server Preference, Information
Request
         ClientID, ServerID , IA_NA , IA_TA , IA_ADDR , Status support
      - Solicit/Request/Advertise/Reply/Infomation-request messages support

  Features available but not validated:

      - Renew/Rebind messages
      - Prefix delegation option support
      - DNS server option support
      - Request option support

  Features under development:

      - Timer events support
          T1(renew)/T2(rebind)/expired(address prefered-lifetime
reached)/deleted(address valid-lifetime reached)
      - Release/Decline/Confirm messages support
      - Client configuration file support
      - Client lease file support
      - Merge prefix delegation configuration file and IPv6 address
assignment file

   Features to be addressed:

      - Unicast/Elapsed time/Authentication/User Class/Vendor
Class/Interface-ID option support
      - Relay agent support.
      - Reconfig/Relay messages support.
