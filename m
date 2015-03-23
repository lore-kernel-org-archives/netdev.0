From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] ucc_geth: Intialize link state to down before register_netdev
Date: Mon, 23 Mar 2015 17:03:59 -0500
Message-ID: <CADRPPNRaCf+TNwTvo_g+j7GhT9tO_H+z7Ury44-2MB4hoa2UFQ@mail.gmail.com>
References: <OF3CCCBC69.C8C0BA7E-ON88257E11.005C1D2B-88257E11.005C420A@selinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: cliff_clark@selinc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:36048 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbbCWWEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:04:00 -0400
Received: by lbbug6 with SMTP id ug6so34075477lbb.3
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 15:03:59 -0700 (PDT)
In-Reply-To: <OF3CCCBC69.C8C0BA7E-ON88257E11.005C1D2B-88257E11.005C420A@selinc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 11:47 AM,  <cliff_clark@selinc.com> wrote:
> ucc_geth was indicating link up after a port is administratively enabled
> even
> when nothing is plugged in.  This causes user-space tools to see a
> spurious link
> up the first time after boot.
>
> Signed-off-by: Cliff Clark <cliff_clark@selinc.com>

Ack for the change, but the commit message is having messy line breaks.

- Leo
