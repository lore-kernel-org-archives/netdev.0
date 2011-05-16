From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: kernel bug relating to networking
Date: Mon, 16 May 2011 18:47:40 +0300
Message-ID: <BANLkTikF3ntwWjV3iuwwCnJhZKJMVHHygQ@mail.gmail.com>
References: <4DD14424.8000003@lockie.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: James <bjlockie@lockie.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DD14424.8000003@lockie.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2011 at 6:35 PM, James <bjlockie@lockie.ca> wrote:
> I originally posted to linux-net@vger.kernel.org but all that list

This should be netdev@vger.kernel.org.

> received in the last day was 3 Russian (spam?) messages.
> I'm hoping here will be less spam.
>
> I'm having a wireless problem that I think is kernel issue.
> kernel-2.6.36.4 is good but recent kernels are bad.
> CompatWireless (recent wireless code) works on kernel-2.6.36.4 so I
> don't think it is the wireless subsystem..
>
> I have a Network controller: Atheros Communications Inc. AR5008 Wirel=
ess
> Network Adapter (rev 01).
>
> "iwlist wlan0 scan | grep SSID" under kernel-2.6.36.4 returns =A0~15 =
APs
> and associates to my AP.
> Recent kernels are bad and return ~0-3 APs and do not associate to my=
 AP.
>
> I need help to debug this.
>
> I think the scans fail whenever dmesg shows this:
>> ath: Failed to stop TX DMA in 100 msec after killing last frame
>> ath: Failed to stop TX DMA!
> It seems to be 100% if I boot a kernel and that message is there, it'=
ll
> be a bad kernel.
>
> I tried:
> $ git clone
> git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-2.6.37.y.g=
it
> $ cd linux-2.6.37.y
> # git tag
> What tag is 2.6.36.4?
>
> v2.6.36
> v2.6.36-rc1
> v2.6.36-rc2
> v2.6.36-rc3
> v2.6.36-rc4
> v2.6.36-rc5
> v2.6.36-rc6
> v2.6.36-rc7
> v2.6.36-rc8
> v2.6.37
> v2.6.37-rc1
> v2.6.37-rc2
> v2.6.37-rc3
> v2.6.37-rc4
> v2.6.37-rc5
> v2.6.37-rc6
> v2.6.37-rc7
> v2.6.37-rc8
> v2.6.37.1
> v2.6.37.2
> v2.6.37.3
> v2.6.37.4
> v2.6.37.5
> v2.6.37.6
>
> Is the next step to do:
> $ git bisect start
> $ git bisect good v2.6.36.4
> $ git bisect bad v2.6.37.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
