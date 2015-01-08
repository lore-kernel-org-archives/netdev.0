From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Wed, 07 Jan 2015 21:41:05 -0800
Message-ID: <1420695665.5947.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
	 <20150105.193614.1827024424476781168.davem@davemloft.net>
	 <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
	 <20150105.195128.794605376092864881.davem@davemloft.net>
	 <CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
	 <CAOxq_8PeZFGGsHoT7Ef0gJezV=UikMQqM0UvQZQcpOywxBOy4w@mail.gmail.com>
	 <1420683594.5947.43.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAOxq_8Pp7fwsV3Y+-LNheziQzP8FXqT3ohgMt7SeEs6+nuGxMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:54655 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbbAHFlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 00:41:09 -0500
Received: by mail-qg0-f42.google.com with SMTP id q108so821034qgd.1
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 21:41:08 -0800 (PST)
In-Reply-To: <CAOxq_8Pp7fwsV3Y+-LNheziQzP8FXqT3ohgMt7SeEs6+nuGxMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-07 at 19:40 -0800, Ani Sinha wrote:

> true but at least those scripts which does only read the values will
> continue to function in a child namespace. In our case, our script
> only reads the max_size sysctl but since it operates from within a
> child namespace, it doesn't find it.
> 
> thoughts?

Fix your script, or do not use namespaces.
