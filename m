From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 3 Jun 2008 20:29:47 +0200
Message-ID: <20080603182947.GB2727@ami.dom.local>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl> <20080603113343.GA4714@ff.dom.local> <48453C70.1040303@trash.net> <Pine.LNX.4.64.0806031449540.3438@bizon.gios.gov.pl> <484542B5.4070401@trash.net> <Pine.LNX.4.64.0806031617310.3438@bizon.gios.gov.pl> <20080603174941.GA2727@ami.dom.local> <48458652.7020309@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:7420 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832AbYFCSaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 14:30:06 -0400
Received: by nf-out-0910.google.com with SMTP id d3so645346nfc.21
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 11:30:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48458652.7020309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 07:58:42PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
...
>> IMHO, adding a safety with e.g. CONFIG_IP_FIB_COMPAT_DEPRECATED
>> (default N) for one stable, letting to change this back in some
>> (probably nonexistent) strange cases, should be enough to keep up
>> appearances...
>
>
> Mhh .. I don't think this is a good solution. Things can
> only break if you actually use the new feature, and if
> you do, you should simply make sure that all software
> running can deal with it. Fixing the routing daemons
> should be a triviality.

But, I think, you've written earlier there is no good solution. And,
probably, there is no way to make sure. This is mainly for appearances
(niceness), and maybe let us know if the problem really existed. But,
I don't insist on this...

Jarek P.
