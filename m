From: Julien Fortin <julien@cumulusnetworks.com>
Subject: Re: [PATCH 00/27] ip: add -json support to 'ip link show'
Date: Thu, 3 Aug 2017 21:05:30 +0200
Message-ID: <CAM_1_KxGSnSagyrrtFmETytjsq22S38A1znj0aBkDrj79m-BPw@mail.gmail.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com> <83479680-2b0a-a668-9c19-c7d9a10291fe@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:35803 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751739AbdHCTFw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 15:05:52 -0400
Received: by mail-vk0-f48.google.com with SMTP id d124so8774014vkf.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 12:05:51 -0700 (PDT)
In-Reply-To: <83479680-2b0a-a668-9c19-c7d9a10291fe@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 3, 2017 at 7:08 PM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
> Hi Julien,
>
> On 08/03/2017 05:54 PM, Julien Fortin wrote:
>>
>> From: Julien Fortin <julien@cumulusnetworks.com>
>
>
> what about
>
> link_veth.c
> iplink_vcan.c
> iplink_vxcan.c
>
> ??

Hello Oliver,

None of these files print any link info data, see struct link_util (.print_opt)

Regards,
Julien.

>
> Regards,
> Oliver
>
>
>>
>> This patch series adds json support to 'ip [-details] link show [dev DEV]'
>> Each patch describes the json schema it adds and provides some examples.
>>
>> Julien Fortin (27):
>>    color: add new COLOR_NONE and disable_color function
>>    ip: add new command line argument -json (mutually exclusive with
>>      -color)
>>    json_writer: add new json handlers (null, float with format, lluint,
>>      hu)
>>    ip: ip_print: add new API to print JSON or regular format output
>>    ip: ipaddress.c: add support for json output
>>    ip: iplink.c: open/close json object for ip -brief -json link show dev
>>      DEV
>>    ip: iplink_bond.c: add json output support
>>    ip: iplink_bond_slave.c: add json output support (info_slave_data)
>>    ip: iplink_hsr.c: add json output support
>>    ip: iplink_bridge.c: add json output support
>>    ip: iplink_bridge_slave.c: add json output support
>>    ip: iplink_can.c: add json output support
>>    ip: iplink_geneve.c: add json output support
>>    ip: iplink_ipoib.c: add json output support
>>    ip: iplink_ipvlan.c: add json output support
>>    ip: iplink_vrf.c: add json output support
>>    ip: iplink_vxlan.c: add json output support
>>    ip: iplink_xdp.c: add json output support
>>    ip: ipmacsec.c: add json output support
>>    ip: link_gre.c: add json output support
>>    ip: link_gre6.c: add json output support
>>    ip: link_ip6tnl.c: add json output support
>>    ip: link_iptnl.c: add json output support
>>    ip: link_vti.c: add json output support
>>    ip: link_vti6.c: add json output support
>>    ip: link_macvlan.c: add json output support
>>    ip: iplink_vlan.c: add json output support
>>
>>   include/color.h          |    2 +
>>   include/json_writer.h    |    9 +
>>   include/utils.h          |    1 +
>>   ip/Makefile              |    2 +-
>>   ip/ip.c                  |    6 +
>>   ip/ip_common.h           |   56 +++
>>   ip/ip_print.c            |  233 ++++++++++
>>   ip/ipaddress.c           | 1089
>> ++++++++++++++++++++++++++++++++--------------
>>   ip/iplink.c              |    2 +
>>   ip/iplink_bond.c         |  231 +++++++---
>>   ip/iplink_bond_slave.c   |   57 ++-
>>   ip/iplink_bridge.c       |  291 ++++++++-----
>>   ip/iplink_bridge_slave.c |  185 +++++---
>>   ip/iplink_can.c          |  276 +++++++++---
>>   ip/iplink_geneve.c       |   86 +++-
>>   ip/iplink_hsr.c          |   36 +-
>>   ip/iplink_ipoib.c        |   30 +-
>>   ip/iplink_ipvlan.c       |    8 +-
>>   ip/iplink_macvlan.c      |   37 +-
>>   ip/iplink_vlan.c         |   62 ++-
>>   ip/iplink_vrf.c          |   13 +-
>>   ip/iplink_vxlan.c        |  161 ++++---
>>   ip/iplink_xdp.c          |   31 +-
>>   ip/ipmacsec.c            |   84 +++-
>>   ip/link_gre.c            |  147 ++++---
>>   ip/link_gre6.c           |  142 ++++--
>>   ip/link_ip6tnl.c         |  172 +++++---
>>   ip/link_iptnl.c          |  155 ++++---
>>   ip/link_vti.c            |   23 +-
>>   ip/link_vti6.c           |   22 +-
>>   lib/color.c              |    9 +-
>>   lib/json_writer.c        |   44 +-
>>   32 files changed, 2668 insertions(+), 1034 deletions(-)
>>   create mode 100644 ip/ip_print.c
>>
>
