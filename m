From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] [TC/U32] Infrastructure for pretty printing
Date: Mon, 21 Apr 2008 09:23:56 -0400
Message-ID: <1208784237.12249.181.camel@localhost>
References: <1208702964.12249.57.camel@localhost>
	 <480C8006.3060708@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.186]:17107 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932591AbYDUNYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 09:24:13 -0400
Received: by gv-out-0910.google.com with SMTP id s4so60555gve.37
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 06:24:09 -0700 (PDT)
In-Reply-To: <480C8006.3060708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-21-04 at 13:52 +0200, Patrick McHardy wrote:

> So far the dump output can be cut-and-pasted and is
> properly parsed again (useful for example for deletion).
> Does that still work with pretty printing?

great idea;-> 
It doesnt do that at the moment - all it tries to do is be equivalent to
the raw format (example the prefix "match" etc).
I think it is worth it though to try what you suggest and i will look
into it and provide an additional patch on top.
IINMistaken you are thinking of a save/restore feature?

The main challenge would be the cruft that dumps at the begining i.e the
sort of:
--
filter protocol ip pref 10 u32
filter protocol ip pref 10 u32 fh 802: ht divisor 1
filter protocol ip pref 10 u32 fh 802::800 order 2048 key ht 802 bkt 0
flowid 1:12
---

I am wondering in the case of -c if we should also go all the way and
dump just sufficient info to be able to reuse it as is to re-insert or
alternatively dump as it is today (for the lines above) and the restore
script would extract enough details out of the above.
Thoughts?

cheers,
jamal

