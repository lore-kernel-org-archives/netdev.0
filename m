From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 3 Jun 2008 19:49:41 +0200
Message-ID: <20080603174941.GA2727@ami.dom.local>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl> <20080603113343.GA4714@ff.dom.local> <48453C70.1040303@trash.net> <Pine.LNX.4.64.0806031449540.3438@bizon.gios.gov.pl> <484542B5.4070401@trash.net> <Pine.LNX.4.64.0806031617310.3438@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:34929 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbYFCRuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 13:50:17 -0400
Received: by nf-out-0910.google.com with SMTP id d3so637191nfc.21
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 10:50:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806031617310.3438@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 05:15:04PM +0200, Krzysztof Oledzki wrote:
>
>
> On Tue, 3 Jun 2008, Patrick McHardy wrote:
...
>> Your patch makes it more predictable, so I'm not completely
>> opposed, but still its just a workaround.
>
> Indeed - it is a workaround but I believe we need it.
>

IMHO, adding a safety with e.g. CONFIG_IP_FIB_COMPAT_DEPRECATED
(default N) for one stable, letting to change this back in some
(probably nonexistent) strange cases, should be enough to keep up
appearances...

Jarek P.
