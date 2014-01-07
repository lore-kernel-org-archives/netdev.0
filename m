From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: Possible to add netfilter hooks to IFB driver?
Date: Tue, 7 Jan 2014 11:18:07 +0000
Message-ID: <20140107111807.38624f74@rainbow.cbg.collabora.co.uk>
References: <522653F1.6090902@ecessa.com>
	<20140106135123.3c7e6645@nehalam.linuxnetplumber.net>
	<CAKTPYJTDj82YM8peU-bbS5OtuXnq1ty4+f-Wyk_bE2LBf4vGmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Brad Johnson <bjohnson@ecessa.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Collins <bsderandrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:60587 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaAGLSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 06:18:11 -0500
In-Reply-To: <CAKTPYJTDj82YM8peU-bbS5OtuXnq1ty4+f-Wyk_bE2LBf4vGmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Jan 2014 15:51:37 -0700
Andrew Collins <bsderandrew@gmail.com> wrote:

> On Mon, Jan 6, 2014 at 2:51 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> >
> > The risk is creating the same races that made IMQ unacceptable.
> > --
> 
> I believe openwrt nowadays uses a TC action which runs the packet
> through prerouting then pulls in the mark off the ct entry into the
> skb, so ingress+IFB can take action on it.

Thanks for the info. I guess the implementation is this one:

https://dev.openwrt.org/browser/trunk/target/linux/generic/patches-3.12/621-sched_act_connmark.patch
https://dev.openwrt.org/browser/trunk/package/network/utils/iproute2/patches/210-add-act_connmark.patch
https://dev.openwrt.org/browser/trunk/package/network/config/qos-scripts/files/usr/lib/qos/generate.sh#L343

> Perhaps a cleaned up version of this would be suitable for upstream?

I don't know but this seems a useful feature to me.

Best regards,
Alban
