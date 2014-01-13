From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 0/2] vxlan updates
Date: Mon, 13 Jan 2014 13:59:04 -0800
Message-ID: <CAHA+R7MO3mxR4CGF+zK9r4DigcG9aHQyBDLrY5rjdx6qCbxSnQ@mail.gmail.com>
References: <1389634880-4138-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:57023 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbaAMV7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 16:59:06 -0500
Received: by mail-la0-f51.google.com with SMTP id c6so857624lan.10
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 13:59:04 -0800 (PST)
In-Reply-To: <1389634880-4138-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 9:41 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Did the split into two patches upon request from Cong Wang.
>
> Changelog:
>
>  v1->v2:
>   - Removed BUG_ON as it's not needed.
>  v2->v3:
>   - Removed dev->reg_state check for netns.
>  v3->v4:
>   - Removed list_del(), we seem to do it in some places and
>     in some others not; we agreed it's not really necessary.
>   - Split patch into 2 patches, notifier part and module
>     unload cleanup part.


Looks good to my eyes, so

Reviewed-by: Cong Wang <cwang@twopensource.com>
