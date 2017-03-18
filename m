From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: SO_BINDTODEVICE in VRFs not working?
Date: Sat, 18 Mar 2017 12:28:18 +0200
Message-ID: <CAKoUArnvBBF=CdzKNBNLOu4ZDw8yG7RJ4J+ruXOQSrcV91U0+Q@mail.gmail.com>
References: <0ac6f5aa-ca23-0cb0-603f-b30758c4c6c3@orlandi.com> <8f53ba28-d897-45c4-862c-3d3850dbd79d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniele Orlandi <daniele@orlandi.com>,
        Netdev <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:36214 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751332AbdCRKye (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 06:54:34 -0400
Received: by mail-it0-f49.google.com with SMTP id w124so46981900itb.1
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 03:53:29 -0700 (PDT)
In-Reply-To: <8f53ba28-d897-45c4-862c-3d3850dbd79d@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>Bind to the VRF device not an interface enslaved to it. I want to add
>the option for enslaved interfaces but have not gotten around to it.

Maybe this should be added as a note/TBD to the VRF documentation
(which does mention setsockopt with SO_BINDTODEVICE):
http://lxr.free-electrons.com/source/Documentation/networking/vrf.txt#L97

Regards,
Rami Rosen
