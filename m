From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Sun, 14 Apr 2013 15:07:26 +0200
Message-ID: <20130414130726.GB2871@netboy>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
 <1365879412-9541-1-git-send-email-willemb@google.com>
 <5169D9C8.8010504@redhat.com>
 <CA+FuTSe1KCPPW=FBXZoTNmri9oPHicuoFeEMKws09PwbyRe-2A@mail.gmail.com>
 <516A8A60.5020003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemb@google.com>,
	Paul Chavent <paul.chavent@onera.fr>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:55800 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab3DNNHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 09:07:40 -0400
Received: by mail-ea0-f177.google.com with SMTP id q14so1789355eaj.8
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 06:07:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <516A8A60.5020003@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 14, 2013 at 12:52:16PM +0200, Daniel Borkmann wrote:
> 
> While going a bit more through the code, I'm wondering .. if we want to support
> TX timestamps, could we also support SW _and_ HW timestamps e.g. similar as in
> sock_recv_timestamp()? I'm asking, because we already allow setting the flags
> for it via sock_tx_timestamp(). This might be good, if possible.

And while you are at it, you could also fix the receive code.

As it stand now, it is fairly useless, since there is no way for user
space to tell which kind of time stamp has been reported. In fact, the
code will silently intermingle hardware and software time stamps. That
is surely a mean trick to play on the users.

Thanks,
Richard
