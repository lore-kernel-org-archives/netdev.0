From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Performance regression with virtio_net
Date: Mon, 31 Jul 2017 21:50:23 +0300
Message-ID: <20170731215007-mutt-send-email-mst@kernel.org>
References: <20170730222552.4fxxnx3jxg4yv65g@multivac.euank.com>
 <20170731161903-mutt-send-email-mst@kernel.org>
 <20170731183800.4jg2qx42sheq7axw@multivac.euank.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: seth.forshee@canonical.com, netdev@vger.kernel.org
To: Euan Kemp <euan.kemp@coreos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52502 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750949AbdGaSuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 14:50:25 -0400
Content-Disposition: inline
In-Reply-To: <20170731183800.4jg2qx42sheq7axw@multivac.euank.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 11:38:00AM -0700, Euan Kemp wrote:
> On Mon, Jul 31, 2017 at 04:26:08PM +0300, Michael S. Tsirkin wrote:
> > I kept this around unchanged from
> > ab7db91705e95ed1bba1304388936fccfa58c992.  That commit had an internal
> > reason not to account for that space: not enough bits to do it.  No
> > longer true so let's account for length exactly.  I'll send a proper
> > patch after a bit of testing, would appreciate reports reports of
> > whether this helps very much.
> 
> I can confirm your patch fixes the issue for me.
> 
> - Euan

Patch posted, thanks everyone.
