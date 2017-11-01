From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 1/2] tc: Add support for the CBS qdisc
Date: Wed, 1 Nov 2017 22:24:25 +0100
Message-ID: <20171101222425.293b80ce@shemminger-XPS-13-9360>
References: <20171026171749.45134-1-jeffrey.t.kirsher@intel.com>
        <20171026171749.45134-2-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:43184 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933478AbdKAVYw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:24:52 -0400
Received: by mail-lf0-f45.google.com with SMTP id a16so4083571lfk.0
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 14:24:52 -0700 (PDT)
In-Reply-To: <20171026171749.45134-2-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Oct 2017 10:17:48 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
> 
> The Credit Based Shaper (CBS) queueing discipline allows bandwidth
> reservation with sub-milisecond precision. It is defined by the
> 802.1Q-2014 specification (section 8.6.8.2 and Annex L).
> 
> The syntax is:
> 
> tc qdisc add dev DEV parent NODE cbs locredit <LOCREDIT>
>    		hicredit <HICREDIT> sendslope <SENDSLOPE>
> 		idleslope <IDLESLOPE>
> 
> (The order is not important)
> 
> Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-next branch (now that CBS is upstream in kernel).
