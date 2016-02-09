From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next 1/7] sock: struct proto hash function may error
Date: Tue, 9 Feb 2016 18:44:02 -0500
Message-ID: <CAEfhGiw+Swe_2f0tEU4JWT1Ss_AxXijnih9jdU1wwa7ABVjCJg@mail.gmail.com>
References: <1454600118-30152-1-git-send-email-kraigatgoog@gmail.com>
	<1454600118-30152-2-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:36368 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbcBIXoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 18:44:06 -0500
Received: by mail-lb0-f196.google.com with SMTP id zr1so106699lbb.3
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 15:44:04 -0800 (PST)
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com. [209.85.217.181])
        by smtp.gmail.com with ESMTPSA id p191sm48718lfp.39.2016.02.09.15.44.03
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 15:44:03 -0800 (PST)
Received: by mail-lb0-f181.google.com with SMTP id x4so1599201lbm.0
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 15:44:03 -0800 (PST)
In-Reply-To: <1454600118-30152-2-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 4, 2016 at 10:35 AM, Craig Gallek <kraigatgoog@gmail.com> wrote:
> From: Craig Gallek <kraig@google.com>
>
> In order to support fast reuseport lookups in TCP, the hash function
> defined in struct proto must be capable of returning an error code.
> This patch changes the function signature of all related hash functions
> to return an integer and handles or propagates this return value at
> all call sites.
>
> Signed-off-by: Craig Gallek <kraig@google.com>
Please see v2, I found a couple warnings introduced by this patch.

Nacked-by: Craig Gallek <kraig@google.com>
