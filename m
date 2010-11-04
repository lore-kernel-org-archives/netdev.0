From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next-2.6 PATCH 2/3] net: remove check for headroom in vlan_dev_create
Date: Wed, 3 Nov 2010 17:46:51 -0700
Message-ID: <AANLkTikWMogcQkrxOZZS65Vuc2EzL_5WrGJb+HD_Chmy@mail.gmail.com>
References: <20101031002232.8691.41201.stgit@jf-dev1-dcblab>
	<20101031002237.8691.6266.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59918 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128Ab0KDAqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 20:46:52 -0400
Received: by wwb13 with SMTP id 13so70446wwb.1
        for <netdev@vger.kernel.org>; Wed, 03 Nov 2010 17:46:51 -0700 (PDT)
In-Reply-To: <20101031002237.8691.6266.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 30, 2010 at 5:22 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> It is possible for the headroom to be smaller then the
> hard_header_len for a short period of time after toggling
> the vlan offload setting.
>
> This is not a hard error and skb_cow_head is called in
> __vlan_put_tag() to resolve this.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jesse Gross <jesse@nicira.com>
