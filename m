From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [oss-drivers] Re: [PATCH net-next 00/12] nfp: add flower app with representors
Date: Thu, 22 Jun 2017 17:39:09 +0300
Message-ID: <CAJ3xEMiqCd9RQYBEANikw0cJRBR9cBRrucRZ1bPZQb2ML7V3PA@mail.gmail.com>
References: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgPWdg8gnAuGgufuxeYt4qDKrs8g+LBgm3BBG9KHnjGsQ@mail.gmail.com>
 <20170620122417.0c60582e@cakuba.netronome.com> <CAJ3xEMjTLs0aDLY_zDerm8o0yPmJktzBDE2rJ=QwXQZeS1+qCg@mail.gmail.com>
 <20170621093212.GA3656@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f180.google.com ([74.125.82.180]:35494 "EHLO
        mail-ot0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdFVOjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 10:39:10 -0400
Received: by mail-ot0-f180.google.com with SMTP id u13so12362397otd.2
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 07:39:10 -0700 (PDT)
In-Reply-To: <20170621093212.GA3656@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 12:32 PM, Simon Horman
<simon.horman@netronome.com> wrote:

> This patchset is in two parts.
>
> The first 9 patches add code to allow representors to be instantiated
> etc... The remaining patches provide the beginning of a flower app which
> makes use of this infrastructure. So I think there is a clear separation
> between representor code, in .../nfp/ and app code that uses representors,
> in this case .../nfp/flower/.

indeed, got it.

> I could have supplied a test app to demonstrate using representors - and
> that is really what the flower app is as of this patchset. But I chose to
> name it flower as it we have follow-up work to make the app actually
> offload flower and at that point that will be come its dominant feature.

As you stated, the separation is there. If got you right, it will be possible to
use representors in non flower apps, and probably also possible to have
the flower app used in a non-SRIOV environment, just fine.

Or.
