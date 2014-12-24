From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 2/4] ip: Allow to easy change network namespace
Date: Wed, 24 Dec 2014 22:33:22 +0200
Message-ID: <20141224203322.GA9728@angus-think.lan>
References: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
 <1418493334-23142-3-git-send-email-vadim4j@gmail.com>
 <20141224123522.15370a16@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:40188 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584AbaLXUna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 15:43:30 -0500
Received: by mail-lb0-f173.google.com with SMTP id z12so7171475lbi.18
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 12:43:28 -0800 (PST)
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
And add Signed-off for Jiri as he was add it for each patch ?
