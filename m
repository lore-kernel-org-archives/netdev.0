From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Broadcom 43xx first results
Date: Tue, 06 Dec 2005 14:05:07 -0500
Message-ID: <4395E0E3.4040601@pobox.com>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de> <20051205190038.04b7b7c1@griffin.suse.cz> <4394892D.2090100@gentoo.org> <20051205195543.5a2e2a8d@griffin.suse.cz> <4394902C.8060100@pobox.com> <20051205195329.GB19964@redhat.com> <20051206151046.GF4038@rama.exocore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, Jiri Benc <jbenc@suse.cz>,
	Joseph Jezak <josejx@gentoo.org>, mbuesch@freenet.de,
	linux-kernel@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932626AbVLFTF3@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20051206151046.GF4038@rama.exocore.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Harald Welte wrote:
> I also think that there is a lack of knowledge on the architecture of
> 802.11 low-level protocols and drivers among many people (including
> myself) in the network community.  Only this way I can explain why there
> are always people who claim that the kernel already has a 802.11
> 'stack'.

This last sentence, regardless of the source, is simply playing with words.

We have 802.11 common code in the kernel, that several drivers are 
using.  Future drivers should modify that common code to suit their 
needs, rather than dropping it and starting from scratch.

	Jeff
