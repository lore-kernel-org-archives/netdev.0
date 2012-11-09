From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: gro vs vlan in myri10ge
Date: Fri, 09 Nov 2012 07:47:02 -0500
Message-ID: <509CFB46.30501@myri.com>
References: <509C6858.6010105@myri.com> <1352428870.19779.496.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:41760 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab2KIMrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 07:47:06 -0500
Received: by mail-gg0-f174.google.com with SMTP id k5so769931ggd.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 04:47:05 -0800 (PST)
In-Reply-To: <1352428870.19779.496.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/12 21:41, Eric Dumazet wrote:
> On Thu, 2012-11-08 at 21:20 -0500, Andrew Gallatin wrote:
<...>
>> Is this (popping vlan tags in the driver) acceptable, or is it
>> too much of a layering violation?
>
> Given GRO assumes NIC does hardware vlan offloading, I guess
> I would chose to do that.
>
> It seems unfortunate to add vlan decap in GRO path, already very
> complex.

OK, then I will prepare & run through q/a a real patch that does this.

Thanks again,

Drew
