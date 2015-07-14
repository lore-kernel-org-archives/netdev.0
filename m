From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/3] rhashtable: allow lookup function to have
 compare function agument
Date: Tue, 14 Jul 2015 11:44:49 +0200
Message-ID: <20150714094449.GD20597@pox.localdomain>
References: <1436834353-1851565-1-git-send-email-tom@herbertland.com>
 <1436834353-1851565-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
	herbert@gondor.apana.org.au
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34935 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754554AbbGNJox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 05:44:53 -0400
Received: by wiga1 with SMTP id a1so93968356wig.0
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 02:44:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1436834353-1851565-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/15 at 05:39pm, Tom Herbert wrote:
> Added rhashtable_lookup_fast_cmpfn which does a lookup in an rhash table
> with the compare function being taken from an argument. This allows
> different compare functions to be used on the same table.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Does this preserve the inlining guarantee? I remember Herbert had
to write this carefully in order to avoid indirect calls.
