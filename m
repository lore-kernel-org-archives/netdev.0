From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: MASQUERADE/SNAT and multiple interfaces with the same IP
Date: Fri, 16 Aug 2013 13:23:31 +0200
Message-ID: <CAKfDRXjqm-7q_2g=KZPCQj2bSU+Th_p3zjXPQvhsaxXOMK2+rw@mail.gmail.com>
References: <CAKfDRXjXkY--PjXAa1m=As+Vf_1__WBokkTAE5BHg+gxsM9Yxw@mail.gmail.com>
	<20130816110443.GB5154@breakpoint.cc>
	<CAKfDRXgNtPgQjtrSL=oVkws6GB_sTv+h+-_GLVvVvpWoEHBRnw@mail.gmail.com>
	<20130816111826.GC5154@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:38317 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754427Ab3HPLXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 07:23:32 -0400
In-Reply-To: <20130816111826.GC5154@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 16, 2013 at 1:18 PM, Florian Westphal <fw@strlen.de> wrote:
>> Does this mean that even when using SNAT, the old mapping is deleted
>> and a new created?
>
> No.

Thank you very much for the help, I see now that I was a little bit
too fast and missed a detail in nf_nat_oif_changed(). If anyone ever
stumbles across the question in the future: SNAT does not set
masq_index and, thus, nf_nat_oif_changed() will always return false.

Have a nice weekend!

-Kristian
