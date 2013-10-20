From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: make socket statistic parseable
Date: Sun, 20 Oct 2013 06:44:22 -0700
Message-ID: <1382276662.3284.51.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382205252-14988-1-git-send-email-hagen@jauu.net>
	 <1382219776.3284.49.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131020132427.GA4514@virgo.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Eric Dumazet <edumazet@google.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:53041 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725Ab3JTNoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 09:44:24 -0400
Received: by mail-pd0-f179.google.com with SMTP id y10so3506900pdj.10
        for <netdev@vger.kernel.org>; Sun, 20 Oct 2013 06:44:24 -0700 (PDT)
In-Reply-To: <20131020132427.GA4514@virgo.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-10-20 at 15:24 +0200, Hagen Paul Pfeifer wrote:
> * Eric Dumazet | 2013-10-19 14:56:16 [-0700]:
> 
> >Seems fine to me, maybe we want to support json for better parsing
> >capabilities ?
> 
> Currently the parsing is straight forward with Python: split for
> whitespaces and subsequent split for colon to get a key/value list. Supporting
> an additional format may be overhead - not sure?! But yeah, JSON formated
> output is nice too. The current format has the advantage that it is human
> readable and "good" machine parseable. Except the first line:
> 

Yes, I was only suggesting adding the -j flag, as done lately on other
iproute2 commands. Default would stay as is ;)

> tcp    ESTAB      0      0 192.168.1.29:58951 208.68.163.218:xmpp-cli
> 
> The line has a strict order, so it is not that hard to write a correct parser.
> 
> 
> Btw: for people not following google plus circus: I wrote an parser for ss(8)
> for plotting TCP stack variables:
> 
> http://research.protocollabs.com/captcp/doc-socket-statistic-module.html

Yeah, I saw that on your Google+ page, very nice tool !

Thanks
