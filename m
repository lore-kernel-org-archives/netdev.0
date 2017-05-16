From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH 4.4-only] openvswitch: clear sender cpu before forwarding packets
Date: Tue, 16 May 2017 12:55:54 -0700
Message-ID: <CAPWQB7EH6u9pE=mJ=5h-mNLFZp+jb+aB8GqfbFOTHDgg8GQ48Q@mail.gmail.com>
References: <1494944710-7901-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: stable@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, ovs dev <dev@openvswitch.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Anoob Soman <anoob.soman@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1494944710-7901-1-git-send-email-anoob.soman@citrix.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16 May 2017 at 07:25, Anoob Soman <anoob.soman@citrix.com> wrote:
> Similar to commit c29390c6dfee ("xps: must clear sender_cpu before
> forwarding") the skb->sender_cpu needs to be cleared before forwarding
> packets.
>
> Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")
> Signed-off-by: Anoob Soman <anoob.soman@citrix.com>

Is this needed for 4.1 too?
