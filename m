From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/8] Bug fixes in ena ethernet driver
Date: Fri, 9 Jun 2017 15:19:54 -0700
Message-ID: <fac900d3-dae3-1c88-ceef-d28294ed7941@gmail.com>
References: <1497046437-20390-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: dwmw@amazon.com, zorik@amazon.com, matua@amazon.com,
        saeedb@amazon.com, msw@amazon.com, aliguori@amazon.com,
        nafea@amazon.com, evgenys@amazon.com
To: netanel@amazon.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35640 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdFIWT7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 18:19:59 -0400
Received: by mail-qt0-f193.google.com with SMTP id x58so18062271qtc.2
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 15:19:58 -0700 (PDT)
In-Reply-To: <1497046437-20390-1-git-send-email-netanel@amazon.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2017 03:13 PM, netanel@amazon.com wrote:
> From: Netanel Belgazal <netanel@amazon.com>
> 
> This patchset contains fixes for the bugs that were discovered so far.

If these are all fixes you should submit them against the "net" tree.
net-next is for features [1].

Since these are fixes, you may also want to provide a Fixes: 12-digit
commit ("commit subject") [2] such that David can queue these patches
for stable trees and this can be retrofitted into kernel distributions.

[1]:
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/netdev-FAQ.txt#n25

[2]:
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/process/submitting-patches.rst#n183

> 
> Netanel Belgazal (8):
>   net: ena: fix rare uncompleted admin command false alarm
>   net: ena: fix bug that might cause hang after consecutive open/close
>     interface.
>   net: ena: add missing return when ena_com_get_io_handlers() fails
>   net: ena: fix race condition between submit and completion admin
>     command
>   net: ena: add missing unmap bars on device removal
>   net: ena: fix theoretical Rx hang on low memory systems
>   net: ena: disable admin msix while working in polling mode
>   net: ena: bug fix in lost tx packets detection mechanism
> 
>  drivers/net/ethernet/amazon/ena/ena_com.c     |  35 +++--
>  drivers/net/ethernet/amazon/ena/ena_ethtool.c |   2 +-
>  drivers/net/ethernet/amazon/ena/ena_netdev.c  | 179 +++++++++++++++++++-------
>  drivers/net/ethernet/amazon/ena/ena_netdev.h  |  16 ++-
>  4 files changed, 168 insertions(+), 64 deletions(-)
> 


-- 
Florian
