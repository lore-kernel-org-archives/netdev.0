From: Takashi Sakamoto <o-takashi@sakamocchi.jp>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Wed, 15 Jun 2016 12:27:38 +0900
Message-ID: <5760CB2A.6090106@sakamocchi.jp>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain> <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@linaro.org>,
	linux-media@vger.kernel.org
To: Henrik Austad <henrik@austad.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On Tue, 14 Jun 2016 19:04:44 +0200, Richard Cochran write:
 >> Well, I guess I should have said, I am not too familiar with the
 >> breadth of current audio hardware, high end or low end.  Of course I
 >> would like to see even consumer devices work with AVB, but it is up to
 >> the ALSA people to make that happen.  So far, nothing has been done,
 >> afaict.

In OSS world, there's few developers for this kind of devices, even if 
it's alsa-project. Furthermore, manufacturerer for recording equipments 
have no interests in OSS.

In short, what we can do for these devices is just to 
reverse-engineering. For models of Ethernet-AVB, it might be just to 
transfer or receive packets, and read them. The devices are still 
black-boxes and we have no ways to reveal their details.

So when you require the details to implement something in your side, few 
developers can tell you, I think.


Regards

Takashi Sakamoto
