From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v2 net-next 3/7] net: add function to retrieve original
 skb device using NAPI ID
Date: Tue, 16 May 2017 11:51:06 +0200
Message-ID: <20170516095106.GC4156@localhost>
References: <20170502101103.30444-1-mlichvar@redhat.com>
 <20170502101103.30444-4-mlichvar@redhat.com>
 <CAF=yD-+n-KF3r1zDiKEQCQsPMkF_DxGZG3AEpzbX4jXFUXcW-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49540 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751488AbdEPJvW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 05:51:22 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+n-KF3r1zDiKEQCQsPMkF_DxGZG3AEpzbX4jXFUXcW-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 02, 2017 at 12:16:13PM -0400, Willem de Bruijn wrote:
> On Tue, May 2, 2017 at 6:10 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> >  /**
> > + *     dev_get_by_napi_id - find a device by napi_id
> > + *     @napi_id: ID of the NAPI struct
> > + *
> > + *     Search for an interface by NAPI ID. Returns %NULL if the device
> > + *     is not found or a pointer to the device. The device has not had
> > + *     its reference counter increased so the caller must be careful
> > + *     about locking. The caller must hold RCU lock.
> 
> Instead of a comment, can check with
> 
>   WARN_ON_ONCE(!rcu_read_lock_held());

The other dev_get_* functions have the same comment, so I think it's
better to keep it for consistency. I'll add the warning and sent
a new series with the other changes you have suggested.

Thanks,

-- 
Miroslav Lichvar
