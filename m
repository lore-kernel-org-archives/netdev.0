From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] tc_act: export all user headers
Date: Mon, 25 Apr 2016 16:05:08 -0700
Message-ID: <20160425160508.2990079d@xeon-e3>
References: <20160422100638.4f4280bf@xeon-e3>
	<20160425.164939.2072274531689250224.davem@davemloft.net>
	<20160425.165244.795853255564768080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@mojatatu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36229 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbcDYXEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 19:04:55 -0400
Received: by mail-pa0-f49.google.com with SMTP id bt5so16594589pac.3
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 16:04:55 -0700 (PDT)
In-Reply-To: <20160425.165244.795853255564768080.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Apr 2016 16:52:44 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Mon, 25 Apr 2016 16:49:39 -0400 (EDT)
> 
> > From: Stephen Hemminger <stephen@networkplumber.org>
> > Date: Fri, 22 Apr 2016 10:06:38 -0700
> > 
> >> The file tc_ife.h was missing from the export list.
> >> Rather than continue to cherry-pick, just export all headers in the directory.
> >> 
> >> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > 
> > Applied.
> 
> Please compile test, pretty please??!?!?
> 
> ./usr/include/linux/tc_act/*.h: No such file or directory
> 
> It looks like you can't expect shell expansions like that to work in
> Kbuild files.

It worked for me but was testing the export function, not the build.
