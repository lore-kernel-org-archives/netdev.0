From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Hooking on L4 Level with process information
Date: Mon, 28 Aug 2017 20:19:00 -0700
Message-ID: <20170828201900.625a10ed@xeon-e3>
References: <CAEDnJmJZ1-4DFtjmzDO1US2HCuHYDkcsa+tk8mN3CZ6vcDLbVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Networking <netdev@vger.kernel.org>
To: Ravish Kumar <ravishk2004@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33504 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdH2DTD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 23:19:03 -0400
Received: by mail-pf0-f175.google.com with SMTP id r62so6663427pfj.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 20:19:03 -0700 (PDT)
In-Reply-To: <CAEDnJmJZ1-4DFtjmzDO1US2HCuHYDkcsa+tk8mN3CZ6vcDLbVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Aug 2017 07:34:51 +0530
Ravish Kumar <ravishk2004@gmail.com> wrote:

> Hi,
> 
> I want to hook tcp/udp packets on L4 Layer and based on process
> information , content want to deny or allow packets.
> 
> Netfilter provides pre/post Routing hooks but not sure that will be
> right place so thought of asking whether my approach is right.
> Also how i can get process information whether this packet is send by
> this process.
> 
> Thoughts /source code reference would be appreciated.
> 
> Regards,
> Ravish

There is not a 1:1 relationship between sockets/files and processes.
