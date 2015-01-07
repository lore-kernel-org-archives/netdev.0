From: Ani Sinha <ani@arista.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Tue, 6 Jan 2015 17:56:26 -0800
Message-ID: <CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
 <20150105.193614.1827024424476781168.davem@davemloft.net> <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
 <20150105.195128.794605376092864881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36329 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbbAGB4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 20:56:47 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn15so604788igb.3
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 17:56:47 -0800 (PST)
In-Reply-To: <20150105.195128.794605376092864881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 5, 2015 at 4:51 PM, David Miller <davem@davemloft.net> wrote:

> The sysctl is kept so that scripts reading it don't suddenly stop
> working.  We can't just remove sysctl values.

Interestingly, one of our scripts did break. It broke because now this
sysctl is only available in the global net namespace and not in the
child namespaces. If not breaking scripts is the fundamental logic in
keeping in sysctl intact, would you guys be open to accepting a patch
where we make this sysctl available for all net namespaces?
