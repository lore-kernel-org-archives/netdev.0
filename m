From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 v2] netxen: qlogic ethernet : Fix endian bug.
Date: Mon, 12 Mar 2012 02:36:59 -0700 (PDT)
Message-ID: <20120312.023659.22154618235290541.davem@davemloft.net>
References: <20120311.234808.1919218898572322534.davem@davemloft.net>
	<CAOD=uF6=2b-s_ErZ8zB+Mmo=gzE8wJdQ+h=TPz7U-sc1ucyw=Q@mail.gmail.com>
	<CAOD=uF4qUhKRpWerFkouqNgzTNRL7DRu3G0kxgTb2E31Ox-=aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: santoshprasadnayak@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOD=uF4qUhKRpWerFkouqNgzTNRL7DRu3G0kxgTb2E31Ox-=aA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Date: Mon, 12 Mar 2012 14:45:38 +0530

> Subject: [PATCH 3/3 v2] netxen: qlogic ethernet : Fix endian bug.
> 
> Change the datatype of "ip_addr" to __be32 as 'ip' should be in
> big endian format.
> 
> Adapter needs "ip address" in big endian format stored at lower 32bit
> of req.word[1]. netxen_config_ipaddr() now receives 'ip' in big endian
> format. To satisfy adapter's need, use memcpy() to copy byte by byte
> of 'ip' into lower 32bit of req.word[1].
> 
> Mac address and serial number of adapter need to be in little endian format.
> Change the data type of the related  variables to __le32 / __le64 or cast it
> explicitly to __le32 / __le64 depending upon the requirement.

This looks a lot better.
