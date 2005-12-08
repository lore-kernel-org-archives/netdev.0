From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Broadcom 43xx first results
Date: Thu, 08 Dec 2005 13:12:44 +0100
Message-ID: <1134043965.2867.45.camel@laptopd505.fenrus.org>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de>
	 <20051205190038.04b7b7c1@griffin.suse.cz> <4394892D.2090100@gentoo.org>
	 <20051205195543.5a2e2a8d@griffin.suse.cz> <4394902C.8060100@pobox.com>
	 <20051208130751.6586c59d@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Joseph Jezak <josejx@gentoo.org>,
	mbuesch@freenet.de, linux-kernel@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de, NetDev <netdev@vger.kernel.org>,
	Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751081AbVLHMMy@vger.kernel.org>
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20051208130751.6586c59d@griffin.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 3. Most of WE calls can be handled by ieee80211 itself. The rest should
> be propagated to a driver in some easier way than requiring driver to
> deal with the whole WE stuff itself. Also, exporting callbacks from
> ieee80211 that driver has to set as particular WE handlers seems to be
> unnecessary complicated.

this argument is analogue to the adaptec SAS driver one about the scsi
host structure. ieee80211 should be a LIBRARY of functions that can do
things, the driver should be able to use the library or not at its own
choice. forcibly making the ieee80211 layer deal with the WE's is the
wrong way for this kind of thing, especially since several layers of the
stack will be optional, so it has to be possible for drivers to go
"until this layer I use the ieee80211 library functions, below that my
own".
