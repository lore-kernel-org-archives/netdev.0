From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] net: Adding support for Cavium
 ThunderX network controller
Date: Mon, 18 May 2015 19:52:30 -0400 (EDT)
Message-ID: <20150518.195230.2247842502863025488.davem@davemloft.net>
References: <1431747401-20847-3-git-send-email-aleksey.makarov@auriga.com>
	<20150518.160931.2235555994068443513.davem@davemloft.net>
	<555A5F1E.1010509@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aleksey.makarov@auriga.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, david.daney@cavium.com,
	sgoutham@cavium.com, mjc@semihalf.com,
	ganapatrao.kulkarni@caviumnetworks.com, tomasz.nowicki@linaro.org,
	rrichter@cavium.com, kamil@semihalf.com,
	tsrinivasulu@caviumnetworks.com, svangala@cavium.com,
	rric@kernel.org, linux-arm-kernel@lists.infradead.org
To: ddaney@caviumnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <555A5F1E.1010509@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@caviumnetworks.com>
Date: Mon, 18 May 2015 14:52:30 -0700

> As I see it there are two options:
> 
> 1) Keep the writeq_relaxed()/readq_relaxed(), but add a comment about
> why they are safe.
> 
> 2) Change the patch so that we are using writeq()/readq() and suffer a
> decrease in performance.

I want a detailed comment added, so #1 would be my choice.

There are more than one set of register accessors, so make sure you
annotate them all.

Thanks.
