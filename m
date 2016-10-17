From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v4] mac80211: move extra crypto data off the stack
Date: Mon, 17 Oct 2016 10:49:01 +0100
Message-ID: <38BC2B4F-4050-4060-9FF0-54212DE3E1CF@linaro.org>
References: <1476693195-14071-1-git-send-email-johannes@sipsolutions.net> <CAKv+Gu-aZhCBvnEQoZUZLDPXCrvgxO1pSd=6EHz+tMB+dFz5hg@mail.gmail.com> <1476696226.19992.13.camel@sipsolutions.net> <CAKv+Gu_ZH9hO_xbVfOfk90CxFJ6ZTz3PKWB1v23LRVzpBrb=oQ@mail.gmail.com> <1476696918.19992.15.camel@sipsolutions.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476696918.19992.15.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> On 17 Oct 2016, at 10:35, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> 
>> On Mon, 2016-10-17 at 10:30 +0100, Ard Biesheuvel wrote:
>> 
>> Yes. But as I replied, setting the req size is not supported atm,
>> although it is reasonable to demand a way to allocate additional data
>> in the request specifically for this issue. So let's proceed with the
>> aead_request_alloc/free patch, but I would like to propose something
>> on the API side to address this particular issue
> 
> Well, if your other patch to make it OK to be on-stack would be applied
> instead, this wouldn't make much sense either :)
> 
> In this particular patch, we could reduce the size of the struct, but I
> don't actually think it'll make a difference to go from 48 to 36 bytes,
> given alignment etc., so I think I'll just leave it as is.
> 
> johannes
