From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next-2.6 PATCH 1/3] 8021q: set hard_header_len when VLAN
 offload features are toggled
Date: Wed, 3 Nov 2010 17:46:42 -0700
Message-ID: <AANLkTim3M-AJnR4KzzNYyxLRcw4L0F3r2CJb6BALEDyT@mail.gmail.com>
References: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:41174 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab0KDAqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 20:46:44 -0400
Received: by wwi17 with SMTP id 17so2096677wwi.1
        for <netdev@vger.kernel.org>; Wed, 03 Nov 2010 17:46:43 -0700 (PDT)
In-Reply-To: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 30, 2010 at 5:22 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> Toggling the vlan tx|rx hw offloads needs to set the hard_header_len
> as well otherwise we end up using LL_RESERVED_SPACE incorrectly.
> This results in pskb_expand_head() being used unnecessarily.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jesse Gross <jesse@nicira.com>
