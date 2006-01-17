From: Stefan Rompf <stefan@loplof.de>
Subject: Re: wireless: recap of current issues (configuration)
Date: Tue, 17 Jan 2006 23:20:48 +0100
Message-ID: <200601172320.49072.stefan@loplof.de>
References: <20060113195723.GB16166@tuxdriver.com> <43CAABD4.3070004@errno.com> <1137355912.2520.97.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Sam Leffler <sam@errno.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964868AbWAQWV3@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1137355912.2520.97.camel@localhost>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag 15 Januar 2006 21:11 schrieb Johannes Berg:

> [iwconfig mode ...]
>
> Yeah, I agree with this, it is much cleaner to handle in the kernel.
> Think about the issues if you have a struct net_device that has 250
> bytes of "payload" for the struct virtual_sta_device in it and you want
> to switch that to a struct virtual_monitor_device. Icky.

Well, nobody forces you to allocate dev->priv together with the net_device, 
you can set and change this pointer yourself. So I don't see a problem here.

Stefan
