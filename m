From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [3.8-rc1] Networking problems after pulling-in net.git#master
Date: Sun, 23 Dec 2012 22:28:01 +0800
Message-ID: <CAM_iQpX0Zp78VuH1Pr7h4u3pPib-DDSHPiwSphjZ+WWG5j2w3Q@mail.gmail.com>
References: <CA+icZUXJeWNceo_y-TSUVzXmjbrauWmCdkgW3EJtr_vpbcrk-A@mail.gmail.com>
	<20121223114213.GB8386@liondog.tnic>
	<CA+icZUXeddp5UZ10ZWTsWLnmegHGJ+VHnr4=oAm34hXgHD2FDg@mail.gmail.com>
	<CA+icZUU2OdNq5WKd7abNNe2eevxZBbMRS0eBGyU_rzjVBAgcOg@mail.gmail.com>
	<CA+icZUVxdp-Lcf4FLfY-80qvVsTQn-ajfh8vn2T=FC6-QbLv7w@mail.gmail.com>
	<CAM_iQpVdqYceHejqyQOn5wqj-xQFjn6E4u5ws4MuoOd=SiVtww@mail.gmail.com>
	<alpine.LFD.2.00.1212231601330.1555@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: sedat.dilek@gmail.com, Borislav Petkov <bp@alien8.de>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1212231601330.1555@ja.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 23, 2012 at 10:10 PM, Julian Anastasov <ja@ssi.bg> wrote:
>> -               memset(dst_ha, 0, dev->addr_len);
>> +               memcpy(dst_ha, dev->broadcast, MAX_ADDR_LEN);
>
>         Use dev->addr_len instead of MAX_ADDR_LEN or
> better provide NULL ptr to arp_send as before the
> "ipv4: arp: fix a lockdep splat in arp_solicit" change,
> for example by keeping dst_ha as pointer and using another
> name for the temp array that is now dst_ha[MAX_ADDR_LEN].
>

OK, I will use a new temp variable.

Thanks.
