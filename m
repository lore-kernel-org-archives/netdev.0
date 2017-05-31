From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/4] ip: Add vrf show commmand
Date: Tue, 30 May 2017 17:56:51 -0700
Message-ID: <20170530175651.3a7f7b82@xeon-e3>
References: <20170527233450.58015-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35157 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbdEaA4x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:56:53 -0400
Received: by mail-pf0-f169.google.com with SMTP id n23so2180902pfb.2
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:56:53 -0700 (PDT)
In-Reply-To: <20170527233450.58015-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 27 May 2017 17:34:46 -0600
David Ahern <dsahern@gmail.com> wrote:

> Refactor ip address to export its capability to save a list of nlmsg's
> for links and its link filter. Use both to add an 'ip vrf show' command
> to list all configured VRF with table id.
> 
> David Ahern (4):
>   ip address: Export ip_linkaddr_list
>   ip address: Move filter struct to ip_common.h
>   ip address: Change print_linkinfo_brief to take filter as an input
>   ip vrf: Add show command
> 
>  include/libnetlink.h |  10 ++++
>  ip/ip_common.h       |  27 ++++++++-
>  ip/ipaddress.c       | 144 +++++++++++++++++++++++-------------------------
>  ip/iplink.c          |   2 +-
>  ip/ipvrf.c           | 153 +++++++++++++++++++++++++++++++++++++++++++++++++--
>  man/man8/ip-vrf.8    |  11 ++++
>  6 files changed, 266 insertions(+), 81 deletions(-)
> 

Looks good, series applied to master.
