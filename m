From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next] inet: introduce a sysctl ip_local_ports_strict_use
Date: Fri, 24 Jul 2015 13:53:36 -0700
Message-ID: <CAM_iQpVP8jMymy6rcQj0TKbWKKJBH6L7G=AzU8opJrWqGvBtNg@mail.gmail.com>
References: <1437610057-13197-1-git-send-email-xiyou.wangcong@gmail.com>
	<20150722223904.20ef9011@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:33938 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754747AbbGXUxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 16:53:36 -0400
Received: by obre1 with SMTP id e1so23201478obr.1
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 13:53:36 -0700 (PDT)
In-Reply-To: <20150722223904.20ef9011@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 22, 2015 at 10:39 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 22 Jul 2015 17:07:37 -0700
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>> For a real example, named randomly selects some port to bind() for
>> security concern. (It doesn't use bind(0) to let kernel to select port
>> because it is not random enough, kernel usually just picks the next
>> available.) When running named on a Mesos controlled host, named would
>> silently fail when it binds a port assigned to a Mesos container.
>
> I think named is trying to workaround security issues that were fixed
> 5 years ago in Linux. The kernel does not just pick the next available
> in current code.
>

Good to know that. I will rephrase the changelog.

Thanks.
