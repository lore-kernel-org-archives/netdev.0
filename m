From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: SO_BINDTODEVICE in VRFs not working?
Date: Sun, 19 Mar 2017 21:08:04 -0600
Message-ID: <bd1ecd9f-81f2-f8ef-e2cc-5c828657aad2@cumulusnetworks.com>
References: <0ac6f5aa-ca23-0cb0-603f-b30758c4c6c3@orlandi.com>
 <8f53ba28-d897-45c4-862c-3d3850dbd79d@cumulusnetworks.com>
 <CAKoUArnvBBF=CdzKNBNLOu4ZDw8yG7RJ4J+ruXOQSrcV91U0+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniele Orlandi <daniele@orlandi.com>,
        Netdev <netdev@vger.kernel.org>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35530 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752467AbdCTDI1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 23:08:27 -0400
Received: by mail-pf0-f178.google.com with SMTP id 20so11726711pfk.2
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 20:08:08 -0700 (PDT)
In-Reply-To: <CAKoUArnvBBF=CdzKNBNLOu4ZDw8yG7RJ4J+ruXOQSrcV91U0+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/18/17 4:28 AM, Rami Rosen wrote:
> Hi,
> 
>> Bind to the VRF device not an interface enslaved to it. I want to add
>> the option for enslaved interfaces but have not gotten around to it.
> 
> Maybe this should be added as a note/TBD to the VRF documentation
> (which does mention setsockopt with SO_BINDTODEVICE):
> http://lxr.free-electrons.com/source/Documentation/networking/vrf.txt#L97


I need a doc update to add the 'ip vrf exec'. I can add a to-do list as
well.
