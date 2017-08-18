From: Julien Fortin <julien@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 json v2 00/27] ip: add -json support to 'ip link show'
Date: Fri, 18 Aug 2017 00:56:59 -0700
Message-ID: <CAM_1_KwmnbpA-cG2NV0Tdo6o_uasZMm9G5vGZRTnmLpFPsmf7A@mail.gmail.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com> <20170817180459.7e75d650@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:35822 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750709AbdHRH5V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 03:57:21 -0400
Received: by mail-ua0-f173.google.com with SMTP id q42so12620608uad.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 00:57:20 -0700 (PDT)
In-Reply-To: <20170817180459.7e75d650@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ack, thanks Stephen.

On Thu, Aug 17, 2017 at 6:04 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu, 17 Aug 2017 10:35:47 -0700
> Julien Fortin <julien@cumulusnetworks.com> wrote:
>
>> From: Julien Fortin <julien@cumulusnetworks.com>
>>
>> This patch series adds json support to 'ip [-details] link show [dev DEV]'
>> Each patch describes the json schema it adds and provides some examples.
>>
>> Julien Fortin (27):
>>   color: add new COLOR_NONE and disable_color function
>>   ip: add new command line argument -json (mutually exclusive with
>>     -color)
>>   json_writer: add new json handlers (null, float with format, lluint,
>>     hu)
>>   ip: ip_print: add new API to print JSON or regular format output
>>   ip: ipaddress.c: add support for json output
>>   ip: iplink.c: open/close json obj for ip -brief -json link show dev
>>     DEV
>>   ip: iplink_bond.c: add json output support
>>   ip: iplink_bond_slave.c: add json output support (info_slave_data)
>>   ip: iplink_hsr.c: add json output support
>>   ip: iplink_bridge.c: add json output support
>>   ip: iplink_bridge_slave.c: add json output support
>>   ip: iplink_can.c: add json output support
>>   ip: iplink_geneve.c: add json output support
>>   ip: iplink_ipoib.c: add json output support
>>   ip: iplink_ipvlan.c: add json output support
>>   ip: iplink_vrf.c: add json output support
>>   ip: iplink_vxlan.c: add json output support
>>   ip: iplink_xdp.c: add json output support
>>   ip: ipmacsec.c: add json output support
>>   ip: link_gre.c: add json output support
>>   ip: link_gre6.c: add json output support
>>   ip: link_ip6tnl.c: add json output support
>>   ip: link_iptnl.c: add json output support
>>   ip: link_vti.c: add json output support
>>   ip: link_vti6.c: add json output support
>>   ip: link_macvlan.c: add json output support
>>   ip: iplink_vlan.c: add json output support
>>
>>  include/color.h          |    2 +
>>  include/json_writer.h    |    9 +
>>  include/utils.h          |    1 +
>>  ip/Makefile              |    2 +-
>>  ip/ip.c                  |    6 +
>>  ip/ip_common.h           |   56 +++
>>  ip/ip_print.c            |  233 ++++++++++
>>  ip/ipaddress.c           | 1064 ++++++++++++++++++++++++++++++++--------------
>>  ip/iplink.c              |    2 +
>>  ip/iplink_bond.c         |  231 ++++++----
>>  ip/iplink_bond_slave.c   |   57 ++-
>>  ip/iplink_bridge.c       |  293 ++++++++-----
>>  ip/iplink_bridge_slave.c |  185 ++++----
>>  ip/iplink_can.c          |  282 ++++++++----
>>  ip/iplink_geneve.c       |   86 +++-
>>  ip/iplink_hsr.c          |   36 +-
>>  ip/iplink_ipoib.c        |   30 +-
>>  ip/iplink_ipvlan.c       |    8 +-
>>  ip/iplink_macvlan.c      |   37 +-
>>  ip/iplink_vlan.c         |   62 ++-
>>  ip/iplink_vrf.c          |   13 +-
>>  ip/iplink_vxlan.c        |  161 ++++---
>>  ip/iplink_xdp.c          |   31 +-
>>  ip/ipmacsec.c            |   84 +++-
>>  ip/link_gre.c            |  147 ++++---
>>  ip/link_gre6.c           |  142 +++++--
>>  ip/link_ip6tnl.c         |  172 +++++---
>>  ip/link_iptnl.c          |  155 ++++---
>>  ip/link_vti.c            |   24 +-
>>  ip/link_vti6.c           |   22 +-
>>  lib/color.c              |   12 +-
>>  lib/json_writer.c        |   44 +-
>>  32 files changed, 2663 insertions(+), 1026 deletions(-)
>>  create mode 100644 ip/ip_print.c
>>
>
> This looks good, Thanks Julien et all.
> Applied to net-next branch.
> You may need to make sure that as new features get added that json support
> continues to work.
>
>
