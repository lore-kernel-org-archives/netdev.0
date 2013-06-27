From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: RTL8192CU on ARM not working
Date: Thu, 27 Jun 2013 09:45:32 -0500
Message-ID: <51CC500C.9050602@lwfinger.net>
References: <20130627081225.GJ5803@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chaoming_li@realsil.com.cn, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Brian Lilly <brian@crystalfontz.com>,
	Brent-Crosby <brent@crystalfontz.com>, Jim Wall <jimwall@q.com>,
	Thomas Petazzoni <thomas@free-electrons.com>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130627081225.GJ5803@lukather>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/27/2013 03:12 AM, Maxime Ripard wrote:
> Hi everyone,
>
> I'm currently trying to use a RTL8192CU on an ARM (Freescale imx28,
> armv5) platform, using 3.10-rc3.
>
> Trouble is, while the chip is correctly detected and you can use iw on it
> without any problem it seems, once you start an association to an access
> point, the association goes on, seems to associate, displaying a WARN()
> message [1] and then, after what looks like a random amount of time (could
> be right away, could be after a few minutes), deassociate [2].
>
> During the time where it's associated, we never seem to transmit any
> packets, while iw reports packets being sent, I guess we can assume that
> they are actually never transmitted as well [3].
>
> What seems odd to me as well is that the signal power reported for the access
> point is excessively high when using iw scan (10 dbm), and once connected, the
> signal strength is -64dbm, which makes quite a huge difference.

That warning is under discussion. See the thread entitled "rtl8192cu: slow path 
warning" in the linux-wireless ML. I will add you to the Cc list on those messages.

You should switch to kernel 3.10-rc7. There are a lot of changes to rtl8192cu in 
that version that are not in -rc3. Those updates mostly affect WPA and WEP 
encryption.

I never take signal power values seriously. Just observe the comments scattered 
throughout the code regarding them.

Larry
