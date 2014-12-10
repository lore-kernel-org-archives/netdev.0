From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: Do not call ndo_dflt_fdb_dump if ndo_fdb_dump
 is defined.
Date: Wed, 10 Dec 2014 22:28:36 +0300
Message-ID: <54889EE4.5010008@cogentembedded.com>
References: <55af638eadcc08cbaa78f82ff6a43cb3.squirrel@poczta.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Hubert Sokolowski <h.sokolowski@wit.edu.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:60818 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932319AbaLJT2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 14:28:40 -0500
Received: by mail-lb0-f180.google.com with SMTP id l4so2868739lbv.25
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 11:28:39 -0800 (PST)
In-Reply-To: <55af638eadcc08cbaa78f82ff6a43cb3.squirrel@poczta.wsisiz.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/10/2014 08:20 PM, Hubert Sokolowski wrote:

> This change restores the semantic that was present
> before 5e6d243587990a588143b9da3974833649595587

    Please also specify that commit's  summary line in parens.

> on how ndo_dflt_fdb_dump is called.
> This semantic is still used for add and del operations
> so let's keep it consistent.
> Driver can still call ndo_dflt_fdb_dump from inside
> its own fdb_dump routine when needed.

    You didn't sign off on the patch, so it can't be applied.

[...]

WBR, Sergei
