From: Daniel Borkmann <borkmann@iogearbox.net>
Subject: Re: Experimental Privacy Functions and TCP SYN Payloads
Date: Wed, 12 Feb 2014 12:35:35 +0100
Message-ID: <52FB5C87.50408@iogearbox.net>
References: <CAM83q7AiCBc5qSH18KhBHYknYf67Pnjkd3JUbC_WrBwefxHJMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Quinn Wood <wood.quinn.s@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM83q7AiCBc5qSH18KhBHYknYf67Pnjkd3JUbC_WrBwefxHJMg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(please cc netdev)

On 02/12/2014 11:25 AM, Quinn Wood wrote:
> If program on host A spoofs the source address of an outgoing IPv4 packet then
> places that address in the first 32 bits of a UDP payload, a program on host B
> that is aware of these behaviors can still reply to the program on host A. [1]
>
> Continuing with this approach the program on host A could encrypt the UDP pay-
> load in a way that the program on host B can decrypt, and effectively reduce
> the ability of others in the wide network to passively determine who host A is
> sending transmissions to while simultaneously ensuring the program on host B
> can respond to the program on host A. [2]
>
> I'm uncertain how to proceed if I want to use TCP for stateful connections.
> The requirement of a handshake before data is handed off to the program means
> this approach won't work out of the box. I'm looking for any insight folks may
> have regarding this.
>
> My original approach to the handshake included setting one of the reserved
> bits in the TCP header to indicate the first 32 bits of the payload were the
> real source address. However this would be reliant on SYN packets containing
> a payload. Does the Linux kernel allow this?
>
> -
>
> [1] Barring any non store-and-forward network behavior like dropping packets
>      with questionable source addresses. Considering recent NTP-related  news
>      this seems to be a not-entirely common activity :)
> [2] This is of course reliant on both programs knowing the proper key for the
>      other.
