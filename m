From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] arch/blackfin: don't generate random mac in
 bfin_get_ether_addr()
Date: Sun, 19 Feb 2012 19:05:19 -0500 (EST)
Message-ID: <20120219.190519.2247992297753168519.davem@davemloft.net>
References: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de>
	<1329412171-20704-2-git-send-email-danny.kukawka@bisect.de>
	<CAMjpGUdJjG3OExzHWd8+FwWsG-vCsL-NVe=ivS5VeeV6G0-_Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: danny.kukawka@bisect.de, linux-kernel@vger.kernel.org,
	dkukawka@suse.de, uclinux-dist-devel@blackfin.uclinux.org,
	lliubbo@gmail.com, sonic.zhang@analog.com,
	paul.gortmaker@windriver.com, realmz6@gmail.com, lars@metafoo.de,
	scott.jiang@analog.com, netdev@vger.kernel.org
To: vapier@gentoo.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMjpGUdJjG3OExzHWd8+FwWsG-vCsL-NVe=ivS5VeeV6G0-_Tw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Frysinger <vapier@gentoo.org>
Date: Thu, 16 Feb 2012 23:38:11 -0500

> On Thu, Feb 16, 2012 at 12:09, Danny Kukawka wrote:
>> Changed bfin_get_ether_addr() to return a state and to
>> set no random mac address if the board don't provide one.
>>
>> Let the caller of bfin_get_ether_addr() set a random mac
>> address if the return value is not 0.
> 
> Acked-by: Mike Frysinger <vapier@gentoo.org>

Applied.
