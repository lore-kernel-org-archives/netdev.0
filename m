From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: sched: run ingress qdisc without locks
Date: Fri, 01 May 2015 10:32:27 -0700
Message-ID: <5543B8AB.8000303@plumgrid.com>
References: <1430450047-5671-1-git-send-email-ast@plumgrid.com> <55436CB2.9070506@mojatatu.com> <554387FB.5040008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:36510 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbbEARca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 13:32:30 -0400
Received: by iebrs15 with SMTP id rs15so93659247ieb.3
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 10:32:30 -0700 (PDT)
In-Reply-To: <554387FB.5040008@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/1/15 7:04 AM, John Fastabend wrote:
>
> Well there is still the TX side, although not as obvious because
> of mq and mqprio. Hopefully by say next LPC we can remove the
> qdisc lock there in many scenarios. Also the netif_tx_lock is
> there as well but many (most?) of the 10G/40G/etc devices can
> create per core descriptor rings. I'll start prodding away on that
> side shortly I suppose.

that will be massive! 'per core descriptor ring' sounds like new
driver API. Looking forward to your work :)
