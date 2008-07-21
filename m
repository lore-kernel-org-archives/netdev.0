From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Mon, 21 Jul 2008 14:13:50 -0500
Message-ID: <4884DFEE.4060003@lwfinger.net>
References: <20080721134506.GA27598@elte.hu> <20080721143023.GA32451@elte.hu> <20080721150446.GA17746@elte.hu> <20080721.082419.70392960.davem@davemloft.net> <4884D2F1.2030704@telenet.be> <20080721190646.GA19044@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Schram <ischram-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, j@w1.fi
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080721190646.GA19044-X9Un+BFzKDI@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * Ian Schram <ischram-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org> wrote:
> 
>> I was looking at this out of interest, but I'm in no way familiar with 
>> the code.
> 
> thanks Ian for the patch, i'll test it.
> 
> Note that it was whitespace damaged, find below a tidied up version of 
> the patch that i've applied to tip/out-of-tree.
> 
> 	Ingo

This patch may be needed to fix error handling in the hw_sim code, but I get the 
crash even with that code disabled. I'm currently bisecting to find the culprit.

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
