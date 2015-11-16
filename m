From: Sathya Perla <sathya.perla@avagotech.com>
Subject: Re: [PATCH net-next 1/2] be2net: remove unused local rsstable array
Date: Mon, 16 Nov 2015 14:19:42 +0530
Message-ID: <CAKvpyk1sSxtMiu+BF4qrkibMtVidJcT=uD4AFq7k3qq_oqSuRQ@mail.gmail.com>
References: <1447411018-11745-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>,
	Ajit Kumar Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:34666 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbbKPItn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 03:49:43 -0500
Received: by ykfs79 with SMTP id s79so228322548ykf.1
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 00:49:42 -0800 (PST)
In-Reply-To: <1447411018-11745-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2015 at 4:06 PM, Ivan Vecera <ivecera@redhat.com> wrote:
>
> Remove rsstable array and its initialization from be_set_rss_hash_opts().
> The array became unused after "e255787 be2net: Support for configurable
> RSS hash key". The initial RSS table is now filled and stored for later
> usage during Rx queue creation.
>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Acked-by: Sathya Perla <sathya.perla@avagotech.com>
