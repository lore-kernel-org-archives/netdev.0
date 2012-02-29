From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH v2] checkpatch: Add some --strict coding style checks
Date: Wed, 29 Feb 2012 16:38:05 +0200
Message-ID: <4F4E384D.2090802@qca.qualcomm.com>
References: <20120221151435.GA19354@tuxdriver.com>	 <20120221.144417.1445117001833888214.davem@davemloft.net>	 <CAMXE1-qB8_5oGey2=Ypa5BitZnye3YqdM=yB8oKCGLvoZu_8HQ@mail.gmail.com>	 <20120221.154053.2103818562080068513.davem@davemloft.net>	 <1329857959.5143.11.camel@joe2Laptop>	 <804857E1F29AAC47BF68C404FC60A18429B3EE@ORSMSX102.amr.corp.intel.com>	 <1329874581.5143.22.camel@joe2Laptop>	 <804857E1F29AAC47BF68C404FC60A18429B8F2@ORSMSX102.amr.corp.intel.com>	 <1329875935.5143.24.camel@joe2Laptop>	 <804857E1F29AAC47BF68C404FC60A18429B98A@ORSMSX102.amr.corp.intel.com>	 <1329968622.5143.46.camel@joe2Laptop>	 <804857E1F29AAC47BF68C404FC60A1842A1D36@ORSMSX102.amr.corp.intel.com> <1330108675.18464.21.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	"Allan, Bruce W" <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"andrei.emeltchenko.news-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org"
	<andrei.emeltchenko.news-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1330108675.18464.21.camel@joe2Laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/24/2012 08:37 PM, Joe Perches wrote:
> Argument alignment across multiple lines should
> match the open parenthesis.
> 
> Logical continuations should be at the end of
> the previous line, not the start of a new line.
> 
> These are not required by CodingStyle so make the
> tests active only when using --strict.
> 
> Improved_by_examples_from: "Bruce W. Allen" <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Thanks Joe, this is very useful for me. I seem to have one false alarm
though:

drivers/net/wireless/ath/ath6kl/txrx.c:464: CHECK: Alignment should
match open parenthesis

This is with patches I haven't sent yet so line numbers most likely
don't match, but the code in question is this:

	if (!IS_ALIGNED((unsigned long) skb->data - HTC_HDR_LENGTH, 4) &&
	    skb_cloned(skb)) {

Apparently the cast "(unsigned long)" causes the false alarm as when I
remove it I don't see the warning anymore.

Kalle
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
