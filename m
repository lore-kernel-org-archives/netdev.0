From: Anoob Soman <anoob.soman@citrix.com>
Subject: Re: [PATCH 4.4-only] openvswitch: clear sender cpu before forwarding
 packets
Date: Wed, 17 May 2017 10:21:09 +0100
Message-ID: <371bcd34-10fa-867f-8bfb-7f61caf11cbe@citrix.com>
References: <1494944710-7901-1-git-send-email-anoob.soman@citrix.com>
 <20170517081933.GA25610@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <stable@vger.kernel.org>, <pshelar@nicira.com>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <dev@openvswitch.org>, <linux-kernel@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170517081933.GA25610@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/05/17 09:19, Greg KH wrote:
> Why is this a non-upstream patch?  What commit in Linus's tree fixed
> this?  Why not just backport that?
>
> thanks,
>
> greg k-h

Agreed, I think it is sensible to backport 52bd2d62ce67 "net: better 
skb->sender_cpu and skb->napi_id cohabitation" to 4.4, rather than 
having a different patch.

I think backport might be required for 4.1 as well, but I haven't checked.

-Anoob.
