From: Sitsofe Wheeler <sitsofe@gmail.com>
Subject: Re: [PATCH net 1/1] hyperv: Fix a bug in netvsc_send()
Date: Tue, 21 Oct 2014 22:16:22 +0100
Message-ID: <CALjAwxj1jHUugt+vtJL7duXfTpdoxmCrwTzRmNHGgOdj+Ju3Aw@mail.gmail.com>
References: <1412530971-29897-1-git-send-email-kys@microsoft.com>
	<20141005.211129.632749242463744635.davem@davemloft.net>
	<20141009133200.GA17134@sucs.org>
	<96f3d4f6b90a461686b23f64aedcb4fc@BL2PR03MB132.namprd03.prod.outlook.com>
	<20141011103630.GA22272@sucs.org>
	<1413911624662.86334@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Long Li <longli@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413911624662.86334@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21 October 2014 18:13, Long Li <longli@microsoft.com> wrote:
> Thanks Sitsofe. This should have been fixed by this patch:
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=f88e67149f97d73c704d6fe6f492edde97463025
>
> Can you give it a try?

Ah this one went mainline a few days ago so I've already been trying
it. Yes it resolves my problem (that system is no longer oopsing on
startup). I'd have added my Tested-by but it's already been committed
:-)

What helped you narrow it down?

-- 
Sitsofe | http://sucs.org/~sits/
