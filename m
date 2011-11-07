From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH] drivers/net/usb/asix:  resync from vendor's copy
Date: Mon, 07 Nov 2011 17:09:04 +0100
Message-ID: <4EB802A0.3050108@suse.cz>
References: <4EA89972.5060101@teksavvy.com> <20111026.194045.2019668159403582571.davem@davemloft.net> <4EA8B283.3010105@teksavvy.com> <20111026.221719.2216112919297458522.davem@davemloft.net> <4EB19BBE.5050602@teksavvy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mark Lord <kernel@teksavvy.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EB19BBE.5050602@teksavvy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2.11.2011 20:36, Mark Lord wrote:
> +static char driver_version[] =
> +	"ASIX USB Ethernet Adapter: v" DRIVER_VERSION \
> +	" " __TIME__ " " __DATE__ "\n";

Please drop the __TIME__ and __DATE__, it makes each build produce
different object files.

Michal
