From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 2/4] ip: Allow to easy change network namespace
Date: Wed, 24 Dec 2014 23:07:00 +0200
Message-ID: <20141224210700.GA24059@angus-think.lan>
References: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
 <1418493334-23142-3-git-send-email-vadim4j@gmail.com>
 <20141224123522.15370a16@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:43357 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbaLXVRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 16:17:08 -0500
Received: by mail-la0-f50.google.com with SMTP id pn19so7320350lab.23
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 13:17:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141224123522.15370a16@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2014 at 12:35:22PM -0800, Stephen Hemminger wrote:
> On Sat, 13 Dec 2014 19:55:32 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Added new '-netns' option to simplify executing following cmd:
> > 
> >     ip netns exec NETNS ip OPTIONS COMMAND OBJECT
> > 
> >     to
> > 
> >     ip -n[etns] NETNS OPTIONS COMMAND OBJECT
> > 
> > e.g.:
> > 
> >     ip -net vnet0 link add br0 type bridge
> >     ip -n vnet0 link
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> 
> Needs to be rebased against current upstream code.
> Will not apply clean any more.
> 
> Please resubmit whole patch series.
Done, fixed conflicts in ip usage func.

Regards,
