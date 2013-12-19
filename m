From: Freddy Xin <freddy@asix.com.tw>
Subject: Re: [PATCH 1/1] AX88179_178A: Add FLAG_HW_IPALIGN to determine whether
 reserving NET_IP_ALIGN bytes for an SKB.
Date: Thu, 19 Dec 2013 11:14:20 +0800
Message-ID: <52B2648C.80500@asix.com.tw>
References: <1386926708-2343-1-git-send-email-freddy@asix.com.tw> <AE90C24D6B3A694183C094C60CF0A2F6026B748A@saturn3.aculab.com> <52AEA3A8.2020906@asix.com.tw> <AE90C24D6B3A694183C094C60CF0A2F6026B7490@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, louis@asix.com.tw, allan@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7490@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2013=E5=B9=B412=E6=9C=8816=E6=97=A5 18:09, David Laight wrote:
>> I was thinking of something like: skb =3D netdev_alloc_skb(dev, leng=
th=20
>> + dev->skb_align, gfp); if (NET_IP_ALIGN && skb && !(ev->driver_flag=
s=20
>> & FLAG_HW_IPALIGN)) skb_reserve(skb, NET_IP_ALIGN); It might even be=
=20
>> reasonable to remove the length adjustment - provided that all the=20
>> later code uses the skb length. David=20

Thanks for your advice.
In the way you advised, does the dev->skb_align equal
to NET_IP_ALIGN in the case that HW doesn't supoort
IP alignment?
In other words, dev->skb_align should be initialized to
NET_IP_ALIGN in USBNET, and I can change its value to
0 in AX88179_178A driver, right?

     Freddy
