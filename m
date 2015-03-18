From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH iproute2] bridge: drop reference to unused option embedded
 from manpage
Date: Wed, 18 Mar 2015 09:52:11 +0900
Message-ID: <5508CC3B.3040306@lab.ntt.co.jp>
References: <1426606450-30133-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:38730 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016AbbCRAwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 20:52:23 -0400
In-Reply-To: <1426606450-30133-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/03/18 0:34, Andy Gospodarek wrote:
> While looking at the manpage, I noticed a reference to 'embedded' that was
> added by this commit:
> 
> 	commit d611682a8c8f28205158e6d3a7d5e2d01db022cc
> 	Author: John Fastabend <john.r.fastabend@intel.com>
> 	Date:   Thu Sep 13 23:50:36 2012 -0700
> 
> 	    iproute2: bridge: finish removing replace option in man pages
> 
> I no longer see any reference to the 'embedded' option in any c- or h-files, so
> it seems worthwhile to remove.

Actually, in addition, "master" option is missing.
Also, the current explanation of "self" looks incorrect and appropriate
for "master".

I wondered if you could fix them together with this... or I will do later.

Thanks,
Toshiaki Makita
