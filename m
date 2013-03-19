From: Parag Warudkar <parag.lkml@gmail.com>
Subject: Re: [PATCH] ath9k : Fix ieee80211 work while going to suspend
Date: Mon, 18 Mar 2013 21:02:26 -0400 (EDT)
Message-ID: <alpine.LFD.2.03.1303182058450.6237@gmail.com>
References: <CAOULuOb0_40EX+6A_HM8eJN7kj9J4WhO9UhZbUUqng1Sfy_SQg@mail.gmail.com> <20130318191340.GA28919@tuxdriver.com> <20130318210308.GD32416@pogo>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Parag Warudkar <parag.lkml@gmail.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@venema.h4ckr.net,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	senthilb@qca.qualcomm.com
To: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130318210308.GD32416@pogo>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 18 Mar 2013, Luis R. Rodriguez wrote:

> 
> Note that what this will do is call later mod_timer() for
> rx_poll_timer, the right thing to do then, which would
> be equivalent to your patch is to modify the ath_start_rx_poll()
> to instead use the new API mod_timer_pending() added on v2.6.30
> via commit 74019224. This would not re-arm the timer if it was
> previously removed.

Thanks for the details Luis. Converting to mod_timer_pending() seems to do 
the trick as well.

Parag
