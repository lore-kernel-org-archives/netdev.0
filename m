From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: switchdev: don't abort unsupported operations
Date: Sat, 11 Jul 2015 10:10:27 -0700
Message-ID: <CAE4R7bAPXXML1pgwAD9MO_22kcmbERB-3ce6tpYy2K+GWPyNGg@mail.gmail.com>
References: <1436572138-16542-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:34256 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbbGKRKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 13:10:47 -0400
In-Reply-To: <1436572138-16542-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2015 at 4:48 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> There is no need to abort attribute setting or object addition, if the
> prepare phase returned operation not supported.
>
> Thus, abort these two transactions only if the error is not -EOPNOTSUPP.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
