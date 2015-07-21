From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ss: Fix crash when dump stats from /proc with
 '-p'
Date: Tue, 21 Jul 2015 07:45:34 +0300
Message-ID: <20150721044534.GA22493@angus-think.lan>
References: <1437421583-20999-1-git-send-email-vadim4j@gmail.com>
 <20150720134340.6c7f8df7@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:34071 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbbGUErk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 00:47:40 -0400
Received: by wgkl9 with SMTP id l9so145670332wgk.1
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 21:47:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150720134340.6c7f8df7@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 20, 2015 at 01:43:40PM -0700, Stephen Hemminger wrote:
> On Mon, 20 Jul 2015 22:46:23 +0300
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > +		if (s->name)
> > +			free(s->name);
> 
> Please don't add unnecessary conditional.
>   free(NULL) is defined to do nothing.

OK, I will re-send, this was from original version.
