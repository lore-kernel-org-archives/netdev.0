From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2 compile and linking errors on Fedora 19
Date: Wed, 1 Nov 2017 07:52:05 +0100
Message-ID: <20171101075205.398005c3@shemminger-XPS-13-9360>
References: <CAM_iQpV07bZscuS5g6nZJ1Ko_RYVv7QyxVtga_Ky5EnbxXhCug@mail.gmail.com>
        <20171031221006.13cf9be8@shemminger-XPS-13-9360>
        <CAM_iQpWQ=jXbkFMaG4siav2+nBUSszN_PtYmw9k__TrJLzQtwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:47711 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750904AbdKAGwb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 02:52:31 -0400
Received: by mail-lf0-f65.google.com with SMTP id k40so1424374lfi.4
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 23:52:30 -0700 (PDT)
In-Reply-To: <CAM_iQpWQ=jXbkFMaG4siav2+nBUSszN_PtYmw9k__TrJLzQtwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 16:28:20 -0700
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Tue, Oct 31, 2017 at 2:10 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> >
> > IPPROTO_MH comes from include/uapi/linux/in6.h
> > Maybe it is trying to use old kernel headers from libc.  
> 
> So newer iproute2 is not supposed to work with older
> kernel header??

Iproute2 has always supplied it's own sanitized kernel headers.
This allows it to be built on older systems where newer definitions in kernel
headers are missing. If you point the kernel header for either kernel package
or glibc, it can't build.

This was done to avoid having to have source full of #ifdef XXX.
Kernel user API is stable enough that newer versions of iproute2 fine.
If a new feature is requested on old kernel it is reported as an error or ignored.
