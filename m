From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v3 0/6] Covscan: Don't access garbage
Date: Mon, 21 Aug 2017 17:18:05 -0700
Message-ID: <20170821171805.7e6a5350@xeon-e3>
References: <20170821092704.21614-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36896 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753979AbdHVASM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:18:12 -0400
Received: by mail-pg0-f43.google.com with SMTP id y129so108446538pgy.4
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 17:18:12 -0700 (PDT)
In-Reply-To: <20170821092704.21614-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Aug 2017 11:26:58 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series collects patches from v1 which resolve situations where
> garbage might be read, either due to missing initialization of
> variables or accessing data which went out of scope.
> 
> Changes since v2:
> - Rebased onto current master branch.
> - Dropped first patch since it is not a real issue.
> 
> Phil Sutter (6):
>   ipaddress: Avoid accessing uninitialized variable lcl
>   iplink_can: Prevent overstepping array bounds
>   ipmaddr: Avoid accessing uninitialized data
>   ss: Use C99 initializer in netlink_show_one()
>   netem/maketable: Check return value of fstat()
>   tc/q_multiq: Don't pass garbage in TCA_OPTIONS
> 
>  ip/ipaddress.c    |  2 +-
>  ip/iplink_can.c   |  4 ++--
>  ip/ipmaddr.c      |  2 +-
>  misc/ss.c         | 13 +++++++------
>  netem/maketable.c |  4 ++--
>  tc/q_multiq.c     |  2 +-
>  6 files changed, 14 insertions(+), 13 deletions(-)
> 

These look fine. Applied.
