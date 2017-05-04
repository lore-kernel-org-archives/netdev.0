From: David Ahern <dsahern@gmail.com>
Subject: Re: Maximum MPLS labels on Linux network stack
Date: Wed, 3 May 2017 20:22:55 -0600
Message-ID: <eb74b9e1-1a5a-f30f-34b5-717231222985@gmail.com>
References: <149211493832787@web33j.yandex.ru>
 <5a408c23-d3e2-aa3e-4574-82521b2255b0@gmail.com>
 <CAPWQB7FFwBFL9h7JoJMF4FuK7JXLrHfo5yg4aHJ4iczSdNU_bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>,
        =?UTF-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <devel-net-ne-vlezay80@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33469 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753911AbdEDCW6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 22:22:58 -0400
Received: by mail-pf0-f171.google.com with SMTP id q20so542379pfg.0
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 19:22:58 -0700 (PDT)
In-Reply-To: <CAPWQB7FFwBFL9h7JoJMF4FuK7JXLrHfo5yg4aHJ4iczSdNU_bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/17 2:21 PM, Joe Stringer wrote:
>> • 8192 MPLS labels
>>
>> Especially interested in the figure 8192 MPLS Labels.

The 8k labels has to be 8k individual routes with a single label (or a
few labels in the stack for the route). In that case you can set
net.mpls.platforms_labels to 10001 and install routes with label values
up to 10000.
