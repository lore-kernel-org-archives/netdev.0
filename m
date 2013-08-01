From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] ax88179_178a: avoid copy of tx tcp packets
Date: Thu, 01 Aug 2013 06:52:45 -0700
Message-ID: <1375365165.10515.143.camel@edumazet-glaptop>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	 <1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	 <1375329066.10515.125.camel@edumazet-glaptop>
	 <CACVXFVNSZJ+ojjBCwYDKsWWvs03aL8BugcX7u483MvBCQCH1sg@mail.gmail.com>
	 <1375333461.10515.133.camel@edumazet-glaptop>
	 <CACVXFVMt-TgRVU+iA3NVuUzJSeXUPGvV89OnDdHaLEB1Ua6aAw@mail.gmail.com>
	 <1375363300.10515.135.camel@edumazet-glaptop>
	 <1375364992.10515.141.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375364992.10515.141.camel@edumazet-glaptop>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-08-01 at 06:49 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> ax88179_tx_fixup() has quite complex code trying to push 8 bytes
> of control data (len/mss), but fails to do it properly for TCP packets,
> incurring an extra copy and point of memory allocation failure.

I forgot to say this patch is for net-next, but depends on following fix
from net tree being applied.

commit 20f0170377264e8449b6987041f0bcc4d746d3ed
("usbnet: do not pretend to support SG/TSO")



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
