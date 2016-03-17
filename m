From: Rick Jones <rick.jones2-ZPxbGqLxI0U@public.gmane.org>
Subject: Re: [Codel] [RFCv2 0/3] mac80211: implement fq codel
Date: Thu, 17 Mar 2016 10:24:47 -0700
Message-ID: <56EAE85F.3010407@hpe.com>
References: <1458123478-1795-1-git-send-email-michal.kazior@tieto.com>
 <CA+BoTQ=65mHN5iLnZjTE+tyEG7nfmCx4NZNbGRF6+VpRaNmOYw@mail.gmail.com>
 <CAA93jw5cUaj_qM+CYHHoRaghLDLC+BUgF4AjT=Oec+SB-zb74g@mail.gmail.com>
 <CAA93jw6tDdiYuginPbUY1DFJLiDxofHMFN6j2BvQPabPmBtuRw@mail.gmail.com>
 <20160316185531.GA1771@localhost>
 <CAGyitvMDEUiNx7HD=XKjXNHnFvZ_gxD_BbQx3AP-57_+dBeD4A@mail.gmail.com>
 <CA+BoTQnFN6VANn=5EUvHc0Dbfh4Zv0HraOto2ySN3_HdOpD7Sg@mail.gmail.com>
 <CAA93jw7TuBLVi9k-+2=J27j-Qs+sS3UNaQNTMF9D2MQ13fQY9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Jasmine Strong <jas-K/XR6QsbQD0@public.gmane.org>,
	"codel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org" <codel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	make-wifi-fast-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
To: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAA93jw7TuBLVi9k-+2=J27j-Qs+sS3UNaQNTMF9D2MQ13fQY9A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/17/2016 10:00 AM, Dave Taht wrote:
> netperf's udp_rr is not how much traffic conventionally behaves. It
> doesn't do tcp slow start or congestion control in particular...

Nor would one expect it to need to, unless one were using "burst mode" 
to have more than one transaction inflight at one time.

And unless one uses the test-specific -e option to provide a very crude 
retransmission mechanism based on a socket read timeout, neither does 
UDP_RR recover from lost datagrams.

happy benchmarking,

rick jones
http://www.netperf.org/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
