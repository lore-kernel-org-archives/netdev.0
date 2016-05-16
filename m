From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip link: Add support for kernel side filtering
Date: Mon, 16 May 2016 11:19:31 -0700
Message-ID: <20160516111931.1aaac4f3@xeon-e3>
References: <1462974718-12860-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36416 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbcEPSTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:19:39 -0400
Received: by mail-pa0-f52.google.com with SMTP id bt5so66650786pac.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 11:19:39 -0700 (PDT)
In-Reply-To: <1462974718-12860-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 May 2016 06:51:58 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Kernel gained support for filtering link dumps with commit dc599f76c22b
> ("net: Add support for filtering link dump by master device and kind").
> Add support to ip link command. If a user passes master device or
> kind to ip link command they are added to the link dump request message.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  include/libnetlink.h |  6 ++++++
>  ip/ipaddress.c       | 33 ++++++++++++++++++++++++++++++++-
>  lib/libnetlink.c     | 28 ++++++++++++++++++++++++++++
>  3 files changed, 66 insertions(+), 1 deletion(-)
> 

Was this tested on older kernels?  Don't want to add something that breaks
when run on old kernels that are in stable distros.
