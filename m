From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 -next] ip: route: add congestion control metric
Date: Wed, 7 Jan 2015 12:22:49 +0200
Message-ID: <20150107102249.GA4019@angus-think.lan>
References: <1420588357-17665-1-git-send-email-dborkman@redhat.com>
 <20150106170926.5bb2d816@urahara>
 <54AD08A9.9000205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>, fw@strlen.de,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:35043 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbbAGKdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 05:33:12 -0500
Received: by mail-la0-f48.google.com with SMTP id gf13so2556075lab.7
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 02:33:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54AD08A9.9000205@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2015 at 11:21:29AM +0100, Daniel Borkmann wrote:
> On 01/07/2015 02:09 AM, Stephen Hemminger wrote:
> >On Wed,  7 Jan 2015 00:52:37 +0100
> >Daniel Borkmann <dborkman@redhat.com> wrote:
> >
> >>+		} else if (matches(*argv, "congctl") == 0) {
> >>+			char cc[16];
> >>+			NEXT_ARG();
> >>+			memset(cc, 0, sizeof(cc));
> >>+			if (strcmp(*argv, "lock") == 0) {
> >>+				mxlock |= (1<<RTAX_CC_ALGO);
> >
> >Unneeded paren
> 
 And what about spaces arount "<<" ?
