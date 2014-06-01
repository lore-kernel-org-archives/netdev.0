From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 2/2] bridge netlink dump interface at par with
 brctl Actually better than brctl showmacs because we can filter by bridge
 port in the kernel
Date: Sun, 01 Jun 2014 08:24:02 -0400
Message-ID: <538B1B62.1060400@mojatatu.com>
References: <1401623780-4297-1-git-send-email-jhs@emojatatu.com> <1401623780-4297-2-git-send-email-jhs@emojatatu.com> <538B19A9.4050607@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:44311 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757513AbaFAMYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 08:24:07 -0400
Received: by mail-ie0-f176.google.com with SMTP id rl12so3450612iec.35
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 05:24:06 -0700 (PDT)
In-Reply-To: <538B19A9.4050607@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Additional note:
This is also on top of Roopa's patch.

cheers,
jamal

On 06/01/14 08:16, Jamal Hadi Salim wrote:
>
> This is mostly to you Vlad since you brought it up earlier.
> I ended using ifm instead of ndm. Currently there is lack of
> symettry - we send requests with ifm and get responses with
> ndms. Unfortunately after spending 2-3 hours I came to the
> conclusion i cant change it without breaking old iproute2s that
> were expecting this behavior. What we have here is a magnitude
> better filtering but we could have done slightly better if we
> were able to use an ndm. A little acrobatics later on to filter
> by vlans may work..
>
> cheers,
> jamal
>
