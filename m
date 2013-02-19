From: Bastian Bittorf <bittorf@bluebottle.com>
Subject: Re: [PATCH] b43: Increase number of RX DMA slots
Date: Tue, 19 Feb 2013 21:01:31 +0100
Message-ID: <20130219200131.GL8730@medion.lan>
References: <1361156480-32566-1-git-send-email-Larry.Finger@lwfinger.net>
 <CACna6rwLgE+o2mcRTemLFAqzdsEoA9Xyx8GyEQTh5qbv1iZ04A@mail.gmail.com>
 <51228ACF.3060500@lwfinger.net>
Reply-To: OpenWrt Development List <openwrt-devel@lists.openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linville@tuxdriver.com, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>, openwrt-devel@lists.openwrt.org
Return-path: <openwrt-devel-bounces@lists.openwrt.org>
Content-Disposition: inline
In-Reply-To: <51228ACF.3060500@lwfinger.net>
List-Unsubscribe: <https://lists.openwrt.org/mailman/options/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=unsubscribe>
List-Archive: <http://lists.openwrt.org/pipermail/openwrt-devel/>
List-Post: <mailto:openwrt-devel@lists.openwrt.org>
List-Help: <mailto:openwrt-devel-request@lists.openwrt.org?subject=help>
List-Subscribe: <https://lists.openwrt.org/mailman/listinfo/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=subscribe>
Errors-To: openwrt-devel-bounces@lists.openwrt.org
Sender: "openwrt-devel" <openwrt-devel-bounces@lists.openwrt.org>
List-Id: netdev.vger.kernel.org

* Larry Finger <Larry.Finger@lwfinger.net> [18.02.2013 21:17]:

> (14e4:4315) units. I think the firmware and DMA can handle it. After
> all, all the TX rings have 256 slots. There is, however, a question
> of the memory. TX only acquires the buffers when needed, but RX has
> to get them in advance, thus 256 slots there will waste a lot of
> memory.

I did some testing with 256 slots and the
"b43-workaround-rx-fifo-overflow.patch" on a very slow board,
an i'am sure, that 128 slots are not enough. kernel-log is here:

http://intercity-vpn.de/files/openwrt/b43test.dmesg.txt

this was a normal download (100mb @ 1 megabyte/s), but if you
do some udp-magic (netperf) you run soon into trouble.

thanks for your work!

bye, bastian / wireless.subsignal.org / weimarnetz e.V.
