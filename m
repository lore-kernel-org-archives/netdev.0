From: Jesse Gross <jesse@nicira.com>
Subject: Re: linux-next: Tree for Jun 21 (netdev: openvswitch)
Date: Fri, 21 Jun 2013 16:18:11 -0700
Message-ID: <CAEP_g=8Oka3RXns4sazz5hX=nbUvXHgjAHCZkhKcwaNvBHxr-g@mail.gmail.com>
References: <20130621181721.11783d80583444868725b62c@canb.auug.org.au> <51C46F9C.7020500@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:60790 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1946207Ab3FUXSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 19:18:34 -0400
Received: by mail-lb0-f171.google.com with SMTP id 13so78064lba.16
        for <netdev@vger.kernel.org>; Fri, 21 Jun 2013 16:18:31 -0700 (PDT)
In-Reply-To: <51C46F9C.7020500@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 21, 2013 at 8:22 AM, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 06/21/13 01:17, Stephen Rothwell wrote:
>> Hi all,
>>
>> Happy solstice!
>>
>> Changes since 20130620:
>>
>
> when CONFIG_INET is not enabled:
>
>   CC      net/openvswitch/flow.o
> In file included from net/openvswitch/flow.c:43:0:
> include/net/ip_tunnels.h: In function 'tunnel_ip_select_ident':
> include/net/ip_tunnels.h:155:3: error: implicit declaration of function '__ip_select_ident' [-Werror=implicit-function-declaration]

Thanks, I just sent out a couple of patches to fix config issues with
the recent tunneling series.
