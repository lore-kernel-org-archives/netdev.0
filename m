From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v4] mac80211: move extra crypto data off the stack
Date: Mon, 17 Oct 2016 11:54:01 +0200
Message-ID: <1476698041.19992.19.camel@sipsolutions.net>
References: <1476693195-14071-1-git-send-email-johannes@sipsolutions.net>
         <CAKv+Gu-aZhCBvnEQoZUZLDPXCrvgxO1pSd=6EHz+tMB+dFz5hg@mail.gmail.com>
         <1476696226.19992.13.camel@sipsolutions.net>
         <CAKv+Gu_ZH9hO_xbVfOfk90CxFJ6ZTz3PKWB1v23LRVzpBrb=oQ@mail.gmail.com>
         <1476696918.19992.15.camel@sipsolutions.net>
         <67161BCC-596E-4DDE-A58E-9195BB5570C2@linaro.org>
         (sfid-20161017_115245_275022_941CE721)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <67161BCC-596E-4DDE-A58E-9195BB5570C2-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> (sfid-20161017_115245_275022_941CE721)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> > Well, if your other patch to make it OK to be on-stack would be
> > applied instead, this wouldn't make much sense either :)
> > 
> 
> Yes but that one only fixes ccm not gcm

Yes, but we can do the same for GCM, no?

> > In this particular patch, we could reduce the size of the struct,
> > but I
> > don't actually think it'll make a difference to go from 48 to 36
> > bytes,
> > given alignment etc., so I think I'll just leave it as is.
> > 
> 
> I understand you are in a hurry, but this is unlikely to be the only
> such issue. I will propose an 'auxdata' feature for the crypto api
> that can be used here, but also for any other occurrence where client
> data assoiciated with the request can no longer be allocated on the
> stack

No objections. I'll merge this anyway today I think, reverting is easy
later.

johannes
