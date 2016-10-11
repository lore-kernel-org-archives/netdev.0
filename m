From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: slab corruption with current -git
Date: Tue, 11 Oct 2016 15:17:09 +0200
Message-ID: <20161011131709.GB24682@unicorn.suse.cz>
References: <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
 <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
 <20161009.235745.860945462339053703.davem@davemloft.net>
 <20161010.042401.637964142015887598.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, aconole@redhat.com, fw@strlen.de,
        viro@zeniv.linux.org.uk, akpm@linux-foundation.org, axboe@fb.com,
        tytso@mit.edu, cl@linux.com, pablo@netfilter.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161010.042401.637964142015887598.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2016 at 04:24:01AM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 09 Oct 2016 23:57:45 -0400 (EDT)
> 
> This means that the netns is possibly getting freed up before we
> unregister the netfilter hooks.

Sounds a bit like the issue discussed here:

  https://marc.info/?l=netfilter-devel&m=146980917627262&w=2

Could it be (partly) the same race condition?

Michal Kubecek
