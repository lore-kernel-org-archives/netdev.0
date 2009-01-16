From: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: hardware time stamping with optional structs in data area
Date: Fri, 16 Jan 2009 11:36:04 +0100
Message-ID: <1232102164.18762.72.camel@pohly-MOBL>
References: <1229352899-31330-1-git-send-email-patrick.ohly@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1229352899-31330-1-git-send-email-patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-12-15 at 15:54 +0100, Patrick Ohly wrote:
> This is the third iteration of a patch series which adds a user space
> API for hardware time stamping of network packets and the
> infrastructure that implements that API. The igb driver is used as
> example for how a network driver can use this new infrastructure.

A new year, another month => time to bring this up once more. The latest
revision of the patch series hasn't brought up further requests for
improvement. There still is growing demand for this feature.

David, do you think it is ready to get included?

John acknowledged the changes to clocksource.h. clocksync is independent
of everything else and not active unless called; if driver developers
don't find it useful, it can be replaced/removed. That leaves the API,
which hasn't triggered any comments so far. As proof that it works as
intended I adapted PTPd to use it:
        http://github.com/pohly/ptpd/tree/master

If further discussion of the API is necessary to get this into mainline,
perhaps including the patches in netdev-next would help to encourage
that discussion?

Is there anything I can do myself, like rebasing against the latest
netdev-next?

Bye, Patrick

--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
