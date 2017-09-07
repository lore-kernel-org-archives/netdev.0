From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 6 Sep 2017 21:57:48 -0700
Message-ID: <CA+55aFzECjnpFWo_ZfbV+vE-5zRst7JfDC0hxnoitCGN0rmE3Q@mail.gmail.com>
References: <20170905.214143.826912481689443792.davem@davemloft.net>
 <CA+55aFw0KNTKFrRHk5hthDGTGgL9BGt9G=x_m9Tz7m_-pN+NoA@mail.gmail.com> <1504757495.5400.89.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "Berg, Johannes" <johannes.berg@intel.com>,
        "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
        linuxwifi <linuxwifi@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>
To: "Coelho, Luciano" <luciano.coelho@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504757495.5400.89.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 6, 2017 at 9:11 PM, Coelho, Luciano
<luciano.coelho@intel.com> wrote:
>
> This seems to be a problem with backwards-compatibility with FW version
> 27.  We are now in version 31[1] and upgrading will probably fix that.

I can confirm that fw version 31 works.

> But obviously the driver should not fail miserably like this with
> version 27, because it claims to support it still.

Not just "claims to support it", but if it's what is shipped with a
fairly recent distro like an up-to-date version of F26, I would really
hope that the driver can still work with it.

> I'm looking into this now and will provide a fix asap.

Thanks,

                  Linus
