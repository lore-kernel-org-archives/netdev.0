From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH] [net]ip_tunnel: the lack of vti_link_ops' dellink() cause
 kernel panic
Date: Wed, 19 Nov 2014 15:10:18 +0800
Message-ID: <CADvbK_cjHr51gvTcrkTmVvB0Q8jME3BZGs2xO46dLatvfP=m2Q@mail.gmail.com>
References: <1416307059-32732-1-git-send-email-lucien.xin@gmail.com>
	<CAHA+R7NKdS_j2MC+-Bcw=hFERODiMw1Z6ju6yw5TvXXHbTXK5A@mail.gmail.com>
	<CAHA+R7N7x5eMKFtyWpOcM_FGJ+9h-K+wLEwzpZya1kiztUo8RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:40752 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932091AbaKSHKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 02:10:20 -0500
Received: by mail-wi0-f180.google.com with SMTP id n3so788957wiv.1
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 23:10:18 -0800 (PST)
In-Reply-To: <CAHA+R7N7x5eMKFtyWpOcM_FGJ+9h-K+wLEwzpZya1kiztUo8RQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>
> Hmm, your fix is correct, but the description is wrong, we should just skip
> the unregister of fb tunnel device like other tunnels. Without ->dellink()
> the fb device is still removed from the global netdev list, this needs to skip,
> otherwise ip_vti0 will disappear from your system.

yes, you are right. the issue only exist in the fb tunnel device, I will change
the description.
