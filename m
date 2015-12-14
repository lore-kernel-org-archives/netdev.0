From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: Another pppoe-related crash
Date: Mon, 14 Dec 2015 17:16:02 +0100
Message-ID: <20151214161602.GA1267@alphalink.fr>
References: <566AE6CA.9080309@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew <nitr0@seti.kr.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:36843 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbLNQQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 11:16:05 -0500
Content-Disposition: inline
In-Reply-To: <566AE6CA.9080309@seti.kr.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 11, 2015 at 05:07:54PM +0200, Andrew wrote:
> I've got another pppoe-related crash on one PPPoE BRAS.
> 
> Kernel is 4.1.13 with patch "pppoe: fix memory corruption in padt work
> structure"
> 
Commit 1acea4f6ce1b ("ppp: fix pppoe_dev deletion condition in
pppoe_release()") is missing from 4.1.13. Can you try with 4.1.14 (or at
least manually apply this patch)?
