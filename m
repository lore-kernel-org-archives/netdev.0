From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v3] geneve: ensure ECN info is handled properly in all
 tx/rx paths
Date: Mon, 21 Sep 2015 18:11:06 -0700
Message-ID: <CAEP_g=8Sf351oYJ240PBfpm+TCirCr=9tbDtMOAi3d7GD99ZVQ@mail.gmail.com>
References: <20150920.222459.2251924175671848436.davem@davemloft.net> <1442845749-23978-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:33907 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650AbbIVBL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 21:11:27 -0400
Received: by lahg1 with SMTP id g1so79529400lah.1
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 18:11:26 -0700 (PDT)
In-Reply-To: <1442845749-23978-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 7:29 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> Partially due to a pre-exising "thinko", the new metadata-based tx/rx
> paths were handling ECN propagation differently than the traditional
> tx/rx paths.  This patch removes the "thinko" (involving multiple
> ip_hdr assignments) on the rx path and corrects the ECN handling on
> both the rx and tx paths.
>
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
