From: Euan Kemp <euan.kemp@coreos.com>
Subject: Re: Performance regression with virtio_net
Date: Mon, 31 Jul 2017 11:38:00 -0700
Message-ID: <20170731183800.4jg2qx42sheq7axw@multivac.euank.com>
References: <20170730222552.4fxxnx3jxg4yv65g@multivac.euank.com>
 <20170731161903-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: seth.forshee@canonical.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34881 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751438AbdGaSiD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 14:38:03 -0400
Received: by mail-pf0-f170.google.com with SMTP id t86so14343847pfe.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 11:38:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170731161903-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 04:26:08PM +0300, Michael S. Tsirkin wrote:
> I kept this around unchanged from
> ab7db91705e95ed1bba1304388936fccfa58c992.  That commit had an internal
> reason not to account for that space: not enough bits to do it.  No
> longer true so let's account for length exactly.  I'll send a proper
> patch after a bit of testing, would appreciate reports reports of
> whether this helps very much.

I can confirm your patch fixes the issue for me.

- Euan
