From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v6 0/2] net/sched: cls_flower: Support matching
 on ICMP
Date: Fri, 9 Dec 2016 07:44:02 +0100
Message-ID: <20161209064401.GA28471@penelope.horms.nl>
References: <CAJ3xEMgBZu0utPE5goTz0V9j+_sFB69P2ziZeEh4oFuruzJYJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@mellanox.com, tom@herbertland.com, netdev@vger.kernel.org,
        ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>,
        Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37935 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753188AbcLIGoG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 01:44:06 -0500
Received: by mail-wm0-f48.google.com with SMTP id f82so12261325wmf.1
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 22:44:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMgBZu0utPE5goTz0V9j+_sFB69P2ziZeEh4oFuruzJYJw@mail.gmail.com>
 <20161208.115810.554381162900423199.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Hi Or,

On Thu, Dec 08, 2016 at 11:58:10AM -0500, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Wed,  7 Dec 2016 13:48:26 +0100
> 
> > this series adds support for matching on ICMP type and code to
> > cls_flower.
> 
> Series applied, thanks Simon.  I guess we'll see some netronome
> offloading of this stuff coming soon? :-)

That is the direction I would like to see this go in.

> Simon and Or, you both added extensions to cls_flower at the same
> time.  Or's changes went in first, so his UAPI numbers did not change.
> Simons, your changes went in next so your numbers did change and
> therefore you will have to recompile any userland components you were
> using for testing.
> 
> Just FYI...

On Thu, Dec 08, 2016 at 10:43:05PM +0200, Or Gerlitz wrote:
> On Thu, Dec 8, 2016 at 6:58 PM, David Miller <davem@davemloft.net> wrote:
> 
> > Simon and Or, you both added extensions to cls_flower at the same
> > time.  Or's changes went in first, so his UAPI numbers did not change.
> > Simons, your changes went in next so your numbers did change and
> > therefore you will have to recompile any userland components you were
> > using for testing.
> 
> Yeah, I guess you had to do some rebasing there for Simon's series...
> thanks for taking care

Likewise, thanks a lot for handling the conflict.
