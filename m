From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH net-next 00/12] nfp: add flower app
 with representors
Date: Thu, 22 Jun 2017 21:09:59 +0200
Message-ID: <20170622190957.GB29904@vergenet.net>
References: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgPWdg8gnAuGgufuxeYt4qDKrs8g+LBgm3BBG9KHnjGsQ@mail.gmail.com>
 <20170620122417.0c60582e@cakuba.netronome.com>
 <CAJ3xEMjTLs0aDLY_zDerm8o0yPmJktzBDE2rJ=QwXQZeS1+qCg@mail.gmail.com>
 <20170621093212.GA3656@vergenet.net>
 <CAJ3xEMiqCd9RQYBEANikw0cJRBR9cBRrucRZ1bPZQb2ML7V3PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:36196 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752429AbdFVTKM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 15:10:12 -0400
Received: by mail-wr0-f174.google.com with SMTP id c11so35932584wrc.3
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 12:10:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiqCd9RQYBEANikw0cJRBR9cBRrucRZ1bPZQb2ML7V3PA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 22, 2017 at 05:39:09PM +0300, Or Gerlitz wrote:
> On Wed, Jun 21, 2017 at 12:32 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> 
> > This patchset is in two parts.
> >
> > The first 9 patches add code to allow representors to be instantiated
> > etc... The remaining patches provide the beginning of a flower app which
> > makes use of this infrastructure. So I think there is a clear separation
> > between representor code, in .../nfp/ and app code that uses representors,
> > in this case .../nfp/flower/.
> 
> indeed, got it.
> 
> > I could have supplied a test app to demonstrate using representors - and
> > that is really what the flower app is as of this patchset. But I chose to
> > name it flower as it we have follow-up work to make the app actually
> > offload flower and at that point that will be come its dominant feature.
> 
> As you stated, the separation is there. If got you right, it will be possible to
> use representors in non flower apps, and probably also possible to have
> the flower app used in a non-SRIOV environment, just fine.

Yes, that is correct.
