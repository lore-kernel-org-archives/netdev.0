From: David Miller <davem@davemloft.net>
Subject: Re: printk_ratelimit and net_ratelimit conflict and tunable
 behavior
Date: Mon, 25 Feb 2008 12:02:10 -0800 (PST)
Message-ID: <20080225.120210.251366287.davem@davemloft.net>
References: <20080220.223219.165157596.davem@davemloft.net>
	<1203577246.7181.241.camel@localhost>
	<7BFDACCD6948EF4D8FE8F4888A91596A016371FA@tx14exm60.ds.mot.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Steve.Hawkes@motorola.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756475AbYBYUBk@vger.kernel.org>
In-Reply-To: <7BFDACCD6948EF4D8FE8F4888A91596A016371FA@tx14exm60.ds.mot.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Hawkes Steve-FSH016" <Steve.Hawkes@motorola.com>
Date: Mon, 25 Feb 2008 09:47:11 -0600

> > .facility = NULL
> 
> How about this?

Actually, for compile time initializations, setting
anything to zero is superfluous and by convention
is not therefore explicitly done in the sources.
