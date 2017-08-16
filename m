From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] net: sched: fix NULL pointer dereference when action
 calls some targets
Date: Wed, 16 Aug 2017 20:39:44 +1200
Message-ID: <CADvbK_cCQY0McHiZFKSTjdGdAjhB6RBej5n=SH2=hsLYC=Xa7w@mail.gmail.com>
References: <0fa9a53725dd661571461cf283ec88cf15f4b139.1501932907.git.lucien.xin@gmail.com>
 <CAM_iQpWcg0a46gJ6Qp3F1pqvvsaJYajmDC2uG_mi9Av_vkFo2w@mail.gmail.com>
 <CADvbK_fuuBrh+eOuhQU+SYs9uazH2TRP+KUmhxU=hNZ=EkOT=Q@mail.gmail.com> <CAM_iQpXbtHDxVjZ=DoTiLXHLQy6q=JVBa66EqSOy95ZbFg-wkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXbtHDxVjZ=DoTiLXHLQy6q=JVBa66EqSOy95ZbFg-wkQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 9, 2017 at 7:33 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Aug 7, 2017 at 7:33 PM, Xin Long <lucien.xin@gmail.com> wrote:
>> On Tue, Aug 8, 2017 at 9:15 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> This looks like a completely API burden?
>> netfilter xt targets are not really compatible with netsched action.
>> I've got to say, the patch is just a way to make checkentry return
>> false and avoid panic. like [1] said
>
> I don't doubt you fix a crash, I am thinking if we can
> "fix" the API instead of fixing the caller.
Hi, Cong,

For now, I don't think it's possible to change APIs or  some of their targets
for the panic caused by action xt calling.

The common way should be fixed in net_sched side.

Given that the issue is very easy to triggered,
let's wait for netfilter's replies for another few days,
otherwise I will repost the fix, agree ?

>
> I am not familiar with this API, so just my 2 cents...
