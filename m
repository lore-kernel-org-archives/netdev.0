From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: ipv6: check route protocol when deleting routes
Date: Tue, 25 Apr 2017 12:54:44 -0600
Message-ID: <341a15e6-4da3-714b-f9f3-c9f3840619a6@gmail.com>
References: <20161216083059.251368-1-grawity@gmail.com>
 <CAKD1Yr3cv+zZgZdjLMt7oac9kKAjFcht+j+JskFD_RsR61LRtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Joel Scherpelz <jscherpelz@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        Greg KH <gregkh@google.com>
To: Lorenzo Colitti <lorenzo@google.com>,
        =?UTF-8?Q?Mantas_Mikul=c4=97nas?= <grawity@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKD1Yr3cv+zZgZdjLMt7oac9kKAjFcht+j+JskFD_RsR61LRtA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/24/17 3:48 AM, Lorenzo Colitti wrote:
> For non-stable kernels, it seems that the proper fix would be:
> 
> 1. Ensure that when an RA creates a route, it properly sets
> rtm_protocol at time of route creation.
> 2. When we dump routes to userspace, we don't overwrite the rtm_protocol.

+1
