From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: BCM43224 hanging [3.2.0-rc4-00248-gb835c0f]
Date: Thu, 8 Dec 2011 18:34:03 +0100
Message-ID: <4EE0F50B.5040407@broadcom.com>
References: <20111201224851.GB20536@ethz.ch>
 <4ED8B610.2010703@broadcom.com> <20111202150128.GC3096@schottelius.org>
 <20111207190821.GA1775@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
To: "Nico Schottelius" <nico-linux-20111201@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	b43-dev@lists.infradead.org, "Greg KH" <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111207190821.GA1775@schottelius.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/07/2011 08:08 PM, Nico Schottelius wrote:
> Update:
> 
> The hang situation always happens, when the nic does *not* have
> a connection. And it still covers all network processes (i.e.
> including sudo, wpa_supplicant, postfix, etc.).
> 
> Starting up the computer, having wpa_supplicant connect successfully,
> everything works fine.
> 
> Until the connection is lost or I issue "select_network 4", which
> changes to another network.
> 
> The problem also exists, if I startup wpa_supplicant and there
> is no network connection available.
> 
> Verified that this bug exists in my pathced 3.1.0-rc6-g443452b
> as well as in 3.2.0-rc4-00248-gb835c0f.
> 
> This is rather nasty, because it forces me to reboot as soon as
> I've started up wlan by accident.
> 
> Is there a workaround available somewhere (besides using USB-LAN)?
> 
> Attached are output of 3.1.0-rc6-g443452b, which is the same for
> all failing versions.
> 
> Cheers,
> 
> Nico

Could you try and see what happens when you kill wpa_supplicant.

Gr. AvS
