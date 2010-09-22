From: Luca Tettamanti <kronos.it@gmail.com>
Subject: Re: [PATCH 1/2] atl1: fix resume
Date: Wed, 22 Sep 2010 21:34:25 +0200
Message-ID: <AANLkTik_0je-8M7VPGy5e05KgOCM8F_rM6b6xUQOPsKy@mail.gmail.com>
References: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
	<1284717403-12913-1-git-send-email-kronos.it@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	atl1-devel@lists.sourceforge.net, jcliburn@gmail.com,
	chris.snook@gmail.com, jie.yang@atheros.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:40336 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754427Ab0IVTe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 15:34:26 -0400
Received: by gyd8 with SMTP id 8so303872gyd.19
        for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 12:34:26 -0700 (PDT)
In-Reply-To: <1284717403-12913-1-git-send-email-kronos.it@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 17, 2010 at 11:56 AM, Luca Tettamanti <kronos.it@gmail.com> wrote:
> adapter->cmb.cmb is initialized when the device is opened and freed when
> it's closed. Accessing it unconditionally during resume results either
> in a crash (NULL pointer dereference, when the interface has not been
> opened yet) or data corruption (when the interface has been used and
> brought down adapter->cmb.cmb points to a deallocated memory area).
>
> Cc: stable@kernel.org
> Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
> Acked-by: Chris Snook <chris.snook@gmail.com>

Ping?

Luca
