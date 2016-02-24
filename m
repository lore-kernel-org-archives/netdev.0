From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: Tools for sampling ethtool --statistics
Date: Wed, 24 Feb 2016 17:21:42 +0200
Message-ID: <CAJ3xEMi-OpWwvBVZVK7v4j7DuY+ksGQ0MwM6pNnF8fT_ZhSLkw@mail.gmail.com>
References: <20160120101311.5266cac6@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36758 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737AbcBXPVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 10:21:43 -0500
Received: by mail-io0-f176.google.com with SMTP id l127so45403739iof.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 07:21:43 -0800 (PST)
In-Reply-To: <20160120101311.5266cac6@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 11:13 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:

> I wrote a small tool[1] to extract ethtool --statistics|-S, sample and
> present it in a more human readable manor.  You might also find this useful...
[..]

> The reason I wrote this script is that the mlx5 driver (Mellanox 100 Gbit/s)
> does not report correct ifconfig stats.  It reports the HW counters,
> not what the network stack is able to handle.  I/we obviously need the
> stack number when working on improving the stack.

Hi Jesper,

So... we finally fixed that, see

https://patchwork.ozlabs.org/patch/587298/
https://patchwork.ozlabs.org/patch/587296/

Or.
