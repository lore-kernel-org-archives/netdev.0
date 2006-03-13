From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Router stops routing after changing MAC Address
Date: Mon, 13 Mar 2006 13:50:09 -0800
Message-ID: <4415E911.8090504@hp.com>
References: <925A849792280C4E80C5461017A4B8A20321F5@mail733.InfraSupportEtc.com> <Pine.LNX.4.61.0603131636470.5608@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Scott <GregScott@InfraSupportEtc.com>,
	Chuck Ebbert <76306.1226@compuserve.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Bart Samwel <bart@samwel.tk>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Simon Mackinlay <smackinlay@mail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932476AbWCMVuN@vger.kernel.org>
To: "linux-os (Dick Johnson)" <linux-os@analogic.com>
In-Reply-To: <Pine.LNX.4.61.0603131636470.5608@chaos.analogic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Anyway, if the device fails, you have
> routers and hosts ARPing the interface, trying to establish a
> route anyway.

But only after what may be a much longer time than the customer is 
willing to accept or able to configure.  I know of a number of HA 
situations where the "new" device is given the "old" MAC just to avoid 
that speicific situation of ARP caches not being updated except after 
quite some time.  Not necessarily on the end-systems, the issue can be 
with intermediate devices (routers).

And if one has to work with static ARP entries to deal (however 
imperfectly) with ARP poisioning or whatnot...

Indeed, there is a large onus on the software doing the MAC override to 
make sure it does not break the required uniqueness.  Just as if one 
were using locally administered MAC addresses.

rick jones
