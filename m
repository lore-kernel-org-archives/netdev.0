From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: patch for PCH_GBE rotten packet (Intel EG20T Platform Controller).
Date: Tue, 26 Jul 2016 09:59:08 -0700
Message-ID: <CAKgT0UeMvwrjyj9VvJu63JjYSWKWvDNg9YLerachV8wezQES_g@mail.gmail.com>
References: <CAMSBNFsZKdptMGnZr4DzRyQj593Snerisyuj_3qb=ducOra1FQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Tom Walsh <tomwalsh73@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:36331 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757246AbcGZQ7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 12:59:10 -0400
Received: by mail-io0-f175.google.com with SMTP id b62so30409355iod.3
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 09:59:09 -0700 (PDT)
In-Reply-To: <CAMSBNFsZKdptMGnZr4DzRyQj593Snerisyuj_3qb=ducOra1FQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 26, 2016 at 9:00 AM, Tom Walsh <tomwalsh73@gmail.com> wrote:
> Not sure how this goes, but, we found a race condition in
> drivers/net/ethernet/oki-semi/pch_gbe/
>
> The attached patch corrects for this.
>
> TomW

So a few minor changes are probably needed.

First we don't recommend the use of camel case for variable names.  So
"resetStatus" should probably be renamed to "reset_status".  Second is
the fact that you seemed to have removed a tab that didn't need to be
removed before the read of the INT_EN register.  Third you need to add
a "Signed-off-by" containing your name and email address.  Finally we
usually require the patches to be emailed inline to avoid having the
attachments stripped.

You might also wan to go through the steps called out in
https://www.kernel.org/doc/Documentation/SubmittingPatches

Hope this helps.

- Alex
