From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 0/5] PF_PACKET timestamping updates
Date: Tue, 23 Apr 2013 20:13:23 +0200
Message-ID: <20130423181322.GC2675@netboy>
References: <1366713572-11978-1-git-send-email-dborkman@redhat.com>
 <CA+FuTSdKPJ0wQUoAKGAh4t=cKs=GQx0tymd8a93GwFGjdB6oAg@mail.gmail.com>
 <5176842F.7040703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemb@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Chavent <Paul.Chavent@onera.fr>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:52239 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756735Ab3DWSNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 14:13:36 -0400
Received: by mail-ea0-f177.google.com with SMTP id q14so385300eaj.8
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 11:13:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5176842F.7040703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 02:53:03PM +0200, Daniel Borkmann wrote:
> 
> Well, for the {RX,TX}_RING there is really no other way except the really
> really ugly possibility to introduce yet another tpacket header with 3
> time-stamp fields (sw, sys, raw). I really do not like that. :-)

Yep. Your solution with the status bits is nicer than the normal
SO_TIMESTAMPING cmsg. I think there is currently no way for the kernel
to produce two or three time stamps at the same time, and so the whole
timestamp triple is rather pointless.
 
> At least here, if you have traffic from different devices, you either get
> what you want (e.g. hw ts), or you'll get a fallback sw ts. That is also
> the case in the current code without this patchset. At least this set would
> solve this issue of telling the user what ts source he sees.

Yes, very good.

Thanks,
Richard
