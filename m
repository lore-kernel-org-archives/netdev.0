From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH for 3.19] rtlwifi: Fix error when accessing unmapped memory in skb
Date: Tue, 23 Dec 2014 08:37:31 +0200
Message-ID: <87a92ehnx0.fsf@kamboji.qca.qualcomm.com>
References: <1419269826-12552-1-git-send-email-Larry.Finger@lwfinger.net>
	<20141222194843.GA7575@zzz> <54989E12.6050808@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <54989E12.6050808@lwfinger.net> (Larry Finger's message of "Mon,
	22 Dec 2014 16:41:22 -0600")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger <Larry.Finger@lwfinger.net> writes:

> You are correct. In trying to get a small patch for stable, I missed
> some important points.
>
> Please look at the attached patch. I think it handles the skb
> allocations correctly. The critical point is that
> _rtl_pci_init_one_rxdesc() cannot be allowed to fail to allocate an
> skb while in the interrupt path. Now, I have already allocated the skb
> before the call and bypassed this routine if the allocation fails.
> After a couple of crashes, this one now works for the case when the
> allocation wouldn't fail anyway. I will likely pull the allocation out
> of _rtl_pci_init_one_rxdesc() in all cases for the final patch.
>
> @Kalle: Please drop the patch I submitted this morning with this
> subject. It would not help the problem. I will resubmit after I am
> sure of the proper fix.

Ack. I'll wait for v2.

-- 
Kalle Valo
