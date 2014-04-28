From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net v2] Altera TSE: Fix DMA secriptor length initialization
Date: Mon, 28 Apr 2014 17:37:29 -0500
Message-ID: <CAOwfj2OsHQjiAE_Nznt-3yoiTx9BESrQ8QdNb6xLqH3=qBJwdg@mail.gmail.com>
References: <1398720181-19450-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nios2-dev@lists.rocketboards.org
To: Tobias Klauser <tobias.klauser@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:53337 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586AbaD1Whb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 18:37:31 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so6507239wib.17
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 15:37:30 -0700 (PDT)
In-Reply-To: <1398720181-19450-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 4:23 PM, Tobias Klauser
<tobias.klauser@gmail.com> wrote:
> sgdma_descrip is a function name as well as the name of a struct. In
> sgdma_initialize(), we should initialize the descriptor length field
> with the actual length of a descriptor not with the size of the
> function. In order to prevent such things from happening in the future,
> rename the function to sgdma_setup_descrip().
>
> Found by sparse which yields the following warning:
>
> drivers/net/ethernet/altera/altera_sgdma.c:74:30: warning: expression using sizeof on a function
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
> v2: patchd rebase against current net tree
>

Thanks for the patch Tobias. Was the misspelling in the subject line
an oversight (secriptor -> descriptor) ?

All the best,

Vince
