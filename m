From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 0/5] PF_PACKET timestamping updates
Date: Tue, 23 Apr 2013 20:07:15 +0200
Message-ID: <20130423180715.GB2675@netboy>
References: <1366713572-11978-1-git-send-email-dborkman@redhat.com>
 <CA+FuTSdKPJ0wQUoAKGAh4t=cKs=GQx0tymd8a93GwFGjdB6oAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Chavent <Paul.Chavent@onera.fr>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:53963 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756963Ab3DWSH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 14:07:27 -0400
Received: by mail-ee0-f41.google.com with SMTP id c50so72298eek.28
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 11:07:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+FuTSdKPJ0wQUoAKGAh4t=cKs=GQx0tymd8a93GwFGjdB6oAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 08:33:50AM -0400, Willem de Bruijn wrote:
> 
> Does this solve the issue you raised, Richard? The patch does not
> change which timestamp is written, so the ring will still fall back on
> software if a hardware timestamp is unavailable. It now reports this
> to the application in tp_status, however, so that it can act
> accordingly (worst case: ignore the timestamp).

Yes, this looks like a nice solution.

Thanks,
Richard
