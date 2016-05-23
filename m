From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v3 5/5] ip: add MACsec support
Date: Mon, 23 May 2016 16:21:42 -0700
Message-ID: <20160523162142.0da12bfa@xeon-e3>
References: <cover.1463585050.git.sd@queasysnail.net>
	<3e4dce017d424cfbd7558a82ddcaf6edf1d03312.1463585050.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36710 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbcEWXV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 19:21:29 -0400
Received: by mail-pf0-f173.google.com with SMTP id c189so97019pfb.3
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 16:21:29 -0700 (PDT)
In-Reply-To: <3e4dce017d424cfbd7558a82ddcaf6edf1d03312.1463585050.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 May 2016 17:35:13 +0200
Sabrina Dubroca <sd@queasysnail.net> wrote:

> +
> +static void print_rx_sc(const char *prefix, __u64 sci, __u8 active, struct rtattr *rxsc_stats, struct rtattr *sa)
> +{

Overall, this looks fine, but could you break some of the really long lines.
In general, I like iproute2 to follow kernel style, and in general stick to
the 80 column recommendation where it makes sense.  Spliting strings or 
stuff in loops may not make sense. There are several places in this code
longer than 100 chars.
