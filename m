From: Saku Ytti <saku@ytti.fi>
Subject: Re: TCP and reordering
Date: Tue, 27 Nov 2012 19:15:20 +0200
Message-ID: <CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
	<50B4F2DA.8020206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35146 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526Ab2K0RPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 12:15:22 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so8576920iea.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 09:15:22 -0800 (PST)
In-Reply-To: <50B4F2DA.8020206@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27 November 2012 19:05, Rick Jones <rick.jones2@hp.com> wrote:

> Packet reordering is supposed to be the exception, not the rule.  Links
> which habitually/constantly introduce reordering are, in my opinion, broken.
> Optimizing for them would be optimizing an error case.

TCP used to be friendly to reordering before fast retransmit
optimization was implemented.

It seems like minimal complexity in TCP algorithm and would
dynamically work correctly depending on situation. It is rather slim
comfort that network should work, when it does not, and you cannot
affect it.

But if the complexity is higher than I expect, then I fully agree,
makes no sense to add it. Reason why reordering can happen in modern
MPLS network is that you have to essentially duck type your traffic,
and sometimes you duck type them wrong and you are then calculating
ECMP on incorrect values, causing packets inside flow to take
different ports.

--
  ++ytti
