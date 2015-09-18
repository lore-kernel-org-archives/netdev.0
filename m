From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2] geneve: remove use of internal IP header when calling IP_ECN_decapsulate
Date: Fri, 18 Sep 2015 13:30:36 -0700
Message-ID: <CAEP_g=-EGH-hfCRYQ8WStY2btq=1g-y=g=PvC_e-aC8QZKugJA@mail.gmail.com>
References: <1442510271-10110-1-git-send-email-linville@tuxdriver.com> <1442522094-876-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:34884 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbbIRUa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 16:30:57 -0400
Received: by lagj9 with SMTP id j9so37566041lag.2
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 13:30:56 -0700 (PDT)
In-Reply-To: <1442522094-876-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 1:34 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> This seems to have been a "thinko".  IP_ECN_decapsulate needs info
> from both internal and external headers.
>
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

This looks good to me although I realized that the transmit path is
also conditional based on !collect_md metadata. I suppose that means
that this difference is intentional and I guess I could see arguments
either way but I still think it is better to be consistent across
different code paths in this respect.
