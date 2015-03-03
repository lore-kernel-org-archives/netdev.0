From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ip tap: Simplify add 'tap' device w/o mode
Date: Tue, 3 Mar 2015 20:53:58 +0200
Message-ID: <20150303185358.GB2227@angus-think.lan>
References: <1425117586-21461-1-git-send-email-vadim4j@gmail.com>
 <20150301140715.0a2c7ef2@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:46098 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095AbbCCTFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 14:05:25 -0500
Received: by widem10 with SMTP id em10so25150286wid.5
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 11:05:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150301140715.0a2c7ef2@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 01, 2015 at 02:07:15PM -0800, Stephen Hemminger wrote:
> On Sat, 28 Feb 2015 11:59:46 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > It allows add 'tap' device w/o specify mode:
> > 
> >     # ip tap add tap0
> > 
> > instead of return error message.
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> 
> No. mode should not depend on device name.
> 
> Also, I noticed that reading kernel code it is possible to
> create a broken tun device if type is not set.
> 

Is it still bad if it checks for 'tap' in 'ip tap' ?
