From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next 1/2] flow dissector: ND support
Date: Thu, 2 Feb 2017 16:58:50 +0100
Message-ID: <20170202155849.GA28482@penelope.horms.nl>
References: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
 <1486031855-10551-2-git-send-email-simon.horman@netronome.com>
 <1486038693.13103.20.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36483 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751147AbdBBP6x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 10:58:53 -0500
Received: by mail-wm0-f45.google.com with SMTP id c85so96703911wmi.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 07:58:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1486038693.13103.20.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Repost due to gmail account problem]

On Thu, Feb 02, 2017 at 04:31:33AM -0800, Eric Dumazet wrote:
> On Thu, 2017-02-02 at 11:37 +0100, Simon Horman wrote:
> > Allow dissection of Neighbour Discovery target IP, and source and
> > destination link-layer addresses for neighbour solicitation and
> > advertisement messages.
> > 
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > ---
> 
> Hi Simon
> 
> Why is this needed ?
> 
> Any code added in flow dissector needs to be extra careful,
> we had various packet of deaths errors recently in this area.

Hi Eric,

there some activity to allow programming of OvS flows in hardware via TC
with the flower classifier. As the ND fields in this patch are part of the
OvS flow key I would like them considered for additions to flower and thus
the dissector to allow compatibility with OvS.

I apologise if any 'deaths' have resulted from my recent work on the
dissector. I am of course very open to ideas on how to avoid any future
incidents.
