From: Sathya Perla <sathya.perla@avagotech.com>
Subject: Re: [PATCH] benet:Make the function be_get_sriov_config have a return
 type of void
Date: Wed, 17 Jun 2015 11:48:37 +0530
Message-ID: <CAKvpyk0oM2oS_Ky4h=ff+QD=iP4EZ7DFrJOZVhBmY3cCKAKvjQ@mail.gmail.com>
References: <1434462161-24955-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ajit Kumar Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:34070 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754770AbbFQGSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 02:18:38 -0400
Received: by ykfl8 with SMTP id l8so32010857ykf.1
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 23:18:38 -0700 (PDT)
In-Reply-To: <1434462161-24955-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2015 at 7:12 PM, Nicholas Krause <xerofoify@gmail.com> wrote:
> This makes the function be_get_sriov_config have a return type of
> void now due to never signaling/nor its only caller the function
> be_alloc_sriov_res checking if this function has returned a
> error code to indicate this particular function has failed
> and the error is unrecoverable from.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>

Hi, you should have prefixed the subject line with "net-next" as this
is a cleanup fix
and so must go to the net-next tree. Thanks!

Acked-by: Sathya Perla <sathya.perla@avagotech.com>
