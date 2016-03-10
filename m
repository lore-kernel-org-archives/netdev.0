From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Thu, 10 Mar 2016 10:57:35 -0800
Message-ID: <CAA93jw47wtioiUUD8ZTm4hFSVL7Uc8ubpSG5urHtWQhfAo1nmQ@mail.gmail.com>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
	<CAA93jw4XsEnp3jTgPL7OKWTJP-83VwRaCdb+foc8nCuqxk3WZA@mail.gmail.com>
	<CA+BoTQk+3jhwK57_fDw0scNCGzu_Edqp9-Beeppz8xj9kSQcoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>
To: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+BoTQk+3jhwK57_fDw0scNCGzu_Edqp9-Beeppz8xj9kSQcoQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>> regular fq_codel uses 1024 and there has not been much reason to
>> change it. In the case of an AP which has more limited memory, 256 or
>> 1024 would be a good setting, per station. I'd stick to 1024 for now.
>
> Do note that the 4096 is shared _across_ station-tid queues. It is not
> per-station. If you have 10 stations you still have 4096 flows
> (actually 4096 + 16*10, because each tid - and there are 16 - has it's
> own fallback flow in case of hash collision on the global flowmap to
> maintain per-sta-tid queuing).

I have to admit I didn't parse this well - still haven't, I think I
need to draw. (got a picture?)

Where is this part happening in the code (or firmware?)

" because each tid - and there are 16 - has it's
 own fallback flow in case of hash collision on the global flowmap to
 maintain per-sta-tid queuing"

"fallback flow - hash collision on global flowmap" - huh?

> With that in mind do you still think 1024 is enough?

Can't answer that question without understanding what you said above.

I assembled a few of the patches to date (your fq_codel patch, avery's
and tims ath9k stuff) and tested them, to no measurable effect,
against linus's tree a day or two back. I also acquired an ath10k card
- would one of these suit?

http://www.amazon.com/gp/product/B011SIMFR8?psc=1&redirect=true&ref_=oh_aui_detailpage_o08_s00
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
