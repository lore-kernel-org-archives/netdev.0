From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2-next 1/4] include: update headers
Date: Thu, 5 Feb 2015 10:26:59 -0800
Message-ID: <20150205102659.7b4a3ebb@urahara>
References: <54C8E3EB.8050904@6wind.com>
	<1422454550-32222-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:42911 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbbBES1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 13:27:01 -0500
Received: by pdjy10 with SMTP id y10so9256295pdj.9
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 10:27:00 -0800 (PST)
In-Reply-To: <1422454550-32222-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jan 2015 15:15:47 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Copy from sanitized headers.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> v2: took last headers from net-next
> 
>  include/linux/if_link.h       |  4 ++++
>  include/linux/neighbour.h     |  1 +
>  include/linux/net_namespace.h | 23 +++++++++++++++++++++++
>  include/linux/rtnetlink.h     |  5 +++++
>  4 files changed, 33 insertions(+)
>  create mode 100644 include/linux/net_namespace.h

All kernel headers for iproute2 must come from the result of:
  $ make headers_install

Please submit a patch to net-next which makes net_namespace.h
(from include/uapi/linux/net_namespace.h) get correctly installed into
usr/include/linux/net_namespace.h

The file is missing from include/uapi/linux/Kbuild
