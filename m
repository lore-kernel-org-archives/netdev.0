From: Andrew Collins <bsderandrew@gmail.com>
Subject: Re: Possible to add netfilter hooks to IFB driver?
Date: Mon, 6 Jan 2014 15:51:37 -0700
Message-ID: <CAKTPYJTDj82YM8peU-bbS5OtuXnq1ty4+f-Wyk_bE2LBf4vGmw@mail.gmail.com>
References: <522653F1.6090902@ecessa.com>
	<20140106135123.3c7e6645@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Brad Johnson <bjohnson@ecessa.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f170.google.com ([209.85.220.170]:46816 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755273AbaAFWvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 17:51:38 -0500
Received: by mail-vc0-f170.google.com with SMTP id ld13so1395325vcb.1
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 14:51:37 -0800 (PST)
In-Reply-To: <20140106135123.3c7e6645@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 6, 2014 at 2:51 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> The risk is creating the same races that made IMQ unacceptable.
> --

I believe openwrt nowadays uses a TC action which runs the packet
through prerouting then pulls in the mark off the ct entry into the
skb, so ingress+IFB can take action on it.

Perhaps a cleaned up version of this would be suitable for upstream?
