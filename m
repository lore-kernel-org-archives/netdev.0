From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: slab corruption with current -git (was Re: [git pull] vfs pile 1 (splice))
Date: Mon, 10 Oct 2016 22:47:50 -0700
Message-ID: <CA+55aFwhscZcWJVLbq+qUgNaN34VwBxFwUR97ktM-7003PcexQ@mail.gmail.com>
References: <CA+55aFz2U83pG0v12E--nd5c6GZAUpVnT3jHuAwHCFk5XbVX0w@mail.gmail.com>
 <20161010005105.GA18349@breakpoint.cc> <f7tbmytkmtr.fsf@redhat.com>
 <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
 <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com> <CA+55aFzcweyWCqq-fRAnJkFB7neKwKsXH=TMcLtRQRs2Wn6XEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>, Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jens Axboe <axboe@fb.com>, "Ted Ts'o" <tytso@mit.edu>,
        Christoph Lameter <cl@linux.com>,
        David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>
To: Aaron Conole <aconole@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzcweyWCqq-fRAnJkFB7neKwKsXH=TMcLtRQRs2Wn6XEQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2016 at 10:39 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I guess I will have to double-check that the slub corruption is gone
> still with that fixed.

So I'm not getting any warnings now from SLUB debugging. So the
original bug seems to not have re-surfaced, and the registration bug
is gone, so now the unregistration doesn't warn about anything either.

But I only rebooted three times.

           Linus
