From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Tue, 29 Nov 2016 15:13:42 -0800
Message-ID: <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
References: <20161129164859.GD26673@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161129164859.GD26673@madcap2.tricolour.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2016 at 8:48 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> On 2016-11-26 17:11, Cong Wang wrote:
>> It is racy on audit_sock, especially on the netns exit path.
>
> I think that is the only place it is racy.  The other places audit_sock
> is set is when the socket failure has just triggered a reset.
>
> Is there a notifier callback for failed or reaped sockets?

Is NETLINK_URELEASE event what you are looking for?
