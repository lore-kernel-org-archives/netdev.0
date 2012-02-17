From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH v2 1/2] arch/blackfin: don't generate random mac in bfin_get_ether_addr()
Date: Thu, 16 Feb 2012 23:38:11 -0500
Message-ID: <CAMjpGUdJjG3OExzHWd8+FwWsG-vCsL-NVe=ivS5VeeV6G0-_Tw@mail.gmail.com>
References: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de> <1329412171-20704-2-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, Danny Kukawka <dkukawka@suse.de>,
	uclinux-dist-devel@blackfin.uclinux.org,
	"David S. Miller" <davem@davemloft.net>,
	Bob Liu <lliubbo@gmail.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Steven Miao <realmz6@gmail.com>,
	Lars-Peter Clausen <lars@metafoo.de>,
	Scott Jiang <scott.jiang@analog.com>, netdev@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329412171-20704-2-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 12:09, Danny Kukawka wrote:
> Changed bfin_get_ether_addr() to return a state and to
> set no random mac address if the board don't provide one.
>
> Let the caller of bfin_get_ether_addr() set a random mac
> address if the return value is not 0.

Acked-by: Mike Frysinger <vapier@gentoo.org>
-mike
