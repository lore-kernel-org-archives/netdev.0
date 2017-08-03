From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 00/27] ip: add -json support to 'ip link show'
Date: Thu, 3 Aug 2017 19:08:09 +0200
Message-ID: <83479680-2b0a-a668-9c19-c7d9a10291fe@hartkopp.net>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com
To: Julien Fortin <julien@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.216]:15178 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751887AbdHCRIR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 13:08:17 -0400
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julien,

On 08/03/2017 05:54 PM, Julien Fortin wrote:
> From: Julien Fortin <julien@cumulusnetworks.com>

what about

link_veth.c
iplink_vcan.c
iplink_vxcan.c

??

Regards,
Oliver

> 
> This patch series adds json support to 'ip [-details] link show [dev DEV]'
> Each patch describes the json schema it adds and provides some examples.
> 
> Julien Fortin (27):
>    color: add new COLOR_NONE and disable_color function
>    ip: add new command line argument -json (mutually exclusive with
>      -color)
>    json_writer: add new json handlers (null, float with format, lluint,
>      hu)
>    ip: ip_print: add new API to print JSON or regular format output
>    ip: ipaddress.c: add support for json output
>    ip: iplink.c: open/close json object for ip -brief -json link show dev
>      DEV
>    ip: iplink_bond.c: add json output support
>    ip: iplink_bond_slave.c: add json output support (info_slave_data)
>    ip: iplink_hsr.c: add json output support
>    ip: iplink_bridge.c: add json output support
>    ip: iplink_bridge_slave.c: add json output support
>    ip: iplink_can.c: add json output support
>    ip: iplink_geneve.c: add json output support
>    ip: iplink_ipoib.c: add json output support
>    ip: iplink_ipvlan.c: add json output support
>    ip: iplink_vrf.c: add json output support
>    ip: iplink_vxlan.c: add json output support
>    ip: iplink_xdp.c: add json output support
>    ip: ipmacsec.c: add json output support
>    ip: link_gre.c: add json output support
>    ip: link_gre6.c: add json output support
>    ip: link_ip6tnl.c: add json output support
>    ip: link_iptnl.c: add json output support
>    ip: link_vti.c: add json output support
>    ip: link_vti6.c: add json output support
>    ip: link_macvlan.c: add json output support
>    ip: iplink_vlan.c: add json output support
> 
>   include/color.h          |    2 +
>   include/json_writer.h    |    9 +
>   include/utils.h          |    1 +
>   ip/Makefile              |    2 +-
>   ip/ip.c                  |    6 +
>   ip/ip_common.h           |   56 +++
>   ip/ip_print.c            |  233 ++++++++++
>   ip/ipaddress.c           | 1089 ++++++++++++++++++++++++++++++++--------------
>   ip/iplink.c              |    2 +
>   ip/iplink_bond.c         |  231 +++++++---
>   ip/iplink_bond_slave.c   |   57 ++-
>   ip/iplink_bridge.c       |  291 ++++++++-----
>   ip/iplink_bridge_slave.c |  185 +++++---
>   ip/iplink_can.c          |  276 +++++++++---
>   ip/iplink_geneve.c       |   86 +++-
>   ip/iplink_hsr.c          |   36 +-
>   ip/iplink_ipoib.c        |   30 +-
>   ip/iplink_ipvlan.c       |    8 +-
>   ip/iplink_macvlan.c      |   37 +-
>   ip/iplink_vlan.c         |   62 ++-
>   ip/iplink_vrf.c          |   13 +-
>   ip/iplink_vxlan.c        |  161 ++++---
>   ip/iplink_xdp.c          |   31 +-
>   ip/ipmacsec.c            |   84 +++-
>   ip/link_gre.c            |  147 ++++---
>   ip/link_gre6.c           |  142 ++++--
>   ip/link_ip6tnl.c         |  172 +++++---
>   ip/link_iptnl.c          |  155 ++++---
>   ip/link_vti.c            |   23 +-
>   ip/link_vti6.c           |   22 +-
>   lib/color.c              |    9 +-
>   lib/json_writer.c        |   44 +-
>   32 files changed, 2668 insertions(+), 1034 deletions(-)
>   create mode 100644 ip/ip_print.c
> 
