From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 28 Jul 2003 02:11:59 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200307280211590888.10957DD9@192.168.128.16>
References: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com>
 <200307280140470646.1078EC67@192.168.128.16>
 <20030727164649.517b2b88.davem@redhat.com>
 <200307280158250677.10891156@192.168.128.16>
 <20030727165831.05904792.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20030727165831.05904792.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

On 27/07/2003 at 16:58 David S. Miller wrote:

>> On 27/07/2003 at 16:46 David S. Miller wrote:
>> >Bas's problem can be solved by him giving a "preferred source"
>> >to each of his IPV4 routes and setting the "arpfilter" sysctl
>> >variable for his devices to "1".
>> 
>> Yes, it's another approach to solve his problem. But he must play with
>routing.
>
>Precisely he must, because he has misconfigured routes for the
>behavior he desires.
>
>His problem is about source address selection when trying to
>contact a given destination.

Bas said:
==
>but it turned out that this wasn't the case. On closer examination it
>turned out that any ARP request to a local IP resulted in a response,
>even if the devices were on different subnets or ethernet segments.
==

It's the "hidden" switch.... again.
I suppose that Bas can confirm it.

>It's totally illogical to say that it's easier for him to patch his
>kernel and reboot it than fix his route configuration.

Sure... it WOULD be the easiest thing if it would be into the kernel main stream. But it isn't, making linux behave different to other OS and systems without any way or feature to make it behave like the others.

Regards,
Carlos Velasco


