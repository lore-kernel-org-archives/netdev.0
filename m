From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: Re: [PATCH 3/5] net/netfilter/ipvs/ip_vs_ctl.c: drop argument range
 check just before the check for equality
Date: Sun, 20 Jul 2014 02:03:21 +0300
Message-ID: <CANZNk83+o9Sc2rir3_2_aTgE65VadY3104a9ve8EMvXWv2ZzUg@mail.gmail.com>
References: <1405697638-23767-1-git-send-email-andrey.krieger.utkin@gmail.com>
	<alpine.LFD.2.11.1407182339160.2273@ja.home.ssi.bg>
	<CANZNk83dJCXAWrQ+i5rh=sdUuiiD5ZhzDua-rjJpBZCzzNGDJA@mail.gmail.com>
	<CANZNk83yhnbw0c77UPnisaJr8AO8XtmUon78vEKGe=PBDrfWMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, dcb314@hotmail.com,
	David Miller <davem@davemloft.net>, kadlec@blackhole.kfki.hu,
	Patrick McHardy <kaber@trash.net>, pablo@netfilter.org,
	Simon Horman <horms@verge.net.au>, wensong@linux-vs.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANZNk83yhnbw0c77UPnisaJr8AO8XtmUon78vEKGe=PBDrfWMw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-07-20 1:59 GMT+03:00 Andrey Utkin <andrey.krieger.utkin@gmail.com>:
> This approach doesn't work, looks because sizeof() values are not
> calculated at preprocessing stage.

What about adding equivalent BUG_ON() statement to __init
ip_vs_register_nl_ioctl(), which "registers" do_ip_vs_set_ctl()
callback?

-- 
Andrey Utkin
