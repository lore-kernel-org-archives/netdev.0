From: Ani Sinha <ani@arista.com>
Subject: Re: [PATCH 1/1] update ip-sysctl.txt documentation
Date: Tue, 6 Jan 2015 15:50:28 -0800
Message-ID: <CAOxq_8NpBrd2AFAUOaZzy4xMVbUjaDWik08Mennwz+93KsS08w@mail.gmail.com>
References: <1420574648-24213-1-git-send-email-ani@arista.com>
 <CAOxq_8OGx9VgSaEimAbNZSWjihNqNBXoVg0m8EPRaNX5jLXZiw@mail.gmail.com> <20150106154824.6f2c9a75@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:36171 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbbAFXvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 18:51:06 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so5005795igb.7
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 15:51:06 -0800 (PST)
In-Reply-To: <20150106154824.6f2c9a75@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 3:48 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue, 6 Jan 2015 14:02:29 -0800
> Ani Sinha <ani@arista.com> wrote:
>
>>  route/max_size - INTEGER
>> -       Maximum number of routes allowed in the kernel.  Increase
>> -       this when using large numbers of interfaces and/or routes.
>> +        Post linux kernel 3.6, this is depricated for ipv4 as route cache is no
>> +        longer used. For ipv6, this is used to limit the maximum number of ipv6
>> +        routes allowed in the kernel.  Increase this when using large
>> numbers of
>> +        interfaces and/or routes.
>
> 1. You used mailer with line wrap which broke the patch.

I used git send-email. Not sure what else to use.

>
> 2. The spelling is not correct 'depricated'

Fixed in the latest patch.
