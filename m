From: Jiri Benc <jbenc@suse.cz>
Subject: Re: wireless: recap of current issues (configuration)
Date: Mon, 16 Jan 2006 15:23:12 +0100
Message-ID: <20060116152312.6b9ddfd0@griffin.suse.cz>
References: <20060113195723.GB16166@tuxdriver.com>
	<20060113212605.GD16166@tuxdriver.com>
	<20060113213011.GE16166@tuxdriver.com>
	<20060113221935.GJ16166@tuxdriver.com>
	<1137191522.2520.63.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750830AbWAPOXQ@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1137191522.2520.63.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Jan 2006 23:32:02 +0100, Johannes Berg wrote:
> IMHO there's not much point in allowing changes. I have a feeling that
> might create icky issues you don't want to have to tackle when the
> solution is easy by just not allowing it. Part of my thinking is that
> different virtual types have different structures associated, so
> changing it needs re-creating structures anyway.

You are right. But it breaks compatibility with iwconfig unless we
emulate 'iwconfig mode' command by deleting and adding interface. This
means some events are generated, hotplug/udev gets involved etc.  In the
worst case it can mean that we end up with interface with a different
name.

> And different virtual
> device types might even be provided by different kernel modules so you
> don't carry around AP mode if you don't need it.

I'm not sure about your concept of softmac modules. I wrote an e-mail
some time ago explaining why I don't think it is useful and I haven't
got any reply. Please, could you answer that e-mail first? (See
http://marc.theaimsgroup.com/?l=linux-netdev&m=113404158202233&w=2)

Could you also explain how would you implement separate module for AP
mode? How would you bind that module to the rest of ieee80211,
especially in the rx path?

Thanks,

-- 
Jiri Benc
SUSE Labs
