From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 1/1] color: use "light" colors for dark
 background
Date: Wed, 1 Mar 2017 10:01:30 -0800
Message-ID: <20170301100130.38f00a3c@xeon-e3>
References: <20170227095527.31134-1-pvorel@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mathias Nyman <m.nyman@iki.fi>,
        Yegor Yefremov <yegorslists@googlemail.com>
To: Petr Vorel <pvorel@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33910 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751950AbdCAS4s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 13:56:48 -0500
Received: by mail-pg0-f44.google.com with SMTP id p5so23053072pga.1
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 10:55:31 -0800 (PST)
In-Reply-To: <20170227095527.31134-1-pvorel@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Feb 2017 10:55:27 +0100
Petr Vorel <pvorel@suse.cz> wrote:

> +void set_color_palette(void)
> +{
> +	char *p = getenv("COLORFGBG");
> +
> +	/*
> +	 * COLORFGBG environment variable usually contains either two or three
> +	 * values separated by semicolons; we want the last value in either case.
> +	 * If this value is 0-6 or 8, background is dark.
> +	 */
> +	if (p && (p = (char *)strrchr(p, ';')) != NULL

Cast here is unnecessary. strrchr is defined as:
       char *strrchr(const char *s, int c);
