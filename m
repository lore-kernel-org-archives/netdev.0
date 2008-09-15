From: "Bosko Radivojevic" <bosko.radivojevic@gmail.com>
Subject: Re: GRE keepalives, again
Date: Mon, 15 Sep 2008 13:45:17 +0200
Message-ID: <d6c8ef150809150445qbd16c5ap7923468008477705@mail.gmail.com>
References: <d6c8ef150809141549m52289f1cr7b4da508b311af1f@mail.gmail.com>
	 <20080914.170302.132520341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20080914.170302.132520341.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 15, 2008 at 2:03 AM, David Miller <davem@davemloft.net> wrote:
> netdev@vger.kernel.org is where networking developers are, added
> to the CC:

Thanks for that!

>> this, and it looks like inner packet never leave ip_gre code. It looks
>> like the journey of the packet ends in  ipgre_ecn_decapsulate() at the
>> very beginning:  if (INET_ECN_is_ce(iph->tos)) {

This one here is not true. I'll keep digging, but I think that this
behavior is not result of a bug. It seems I just don't know how to
turn the feature off ;)

Sincerely,
Bosko
