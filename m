From: Ani Sinha <ani@arista.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Wed, 7 Jan 2015 17:25:13 -0800
Message-ID: <CAOxq_8PeZFGGsHoT7Ef0gJezV=UikMQqM0UvQZQcpOywxBOy4w@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
 <20150105.193614.1827024424476781168.davem@davemloft.net> <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
 <20150105.195128.794605376092864881.davem@davemloft.net> <CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:38294 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbbAHBZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 20:25:34 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so7106007ieb.3
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 17:25:33 -0800 (PST)
In-Reply-To: <CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hey guys,

On Tue, Jan 6, 2015 at 5:56 PM, Ani Sinha <ani@arista.com> wrote:
> On Mon, Jan 5, 2015 at 4:51 PM, David Miller <davem@davemloft.net> wrote:
>
>> The sysctl is kept so that scripts reading it don't suddenly stop
>> working.  We can't just remove sysctl values.
>
> Interestingly, one of our scripts did break. It broke because now this
> sysctl is only available in the global net namespace and not in the
> child namespaces. If not breaking scripts is the fundamental logic in
> keeping in sysctl intact, would you guys be open to accepting a patch
> where we make this sysctl available for all net namespaces?

Any thoughts on this?
