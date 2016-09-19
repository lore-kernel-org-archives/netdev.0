From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 1/2] ptp_clock: allow for it to be optional
Date: Mon, 19 Sep 2016 14:09:39 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1609191403210.9311@knanqh.ubzr>
References: <1474257070-4255-1-git-send-email-nicolas.pitre@linaro.org> <1474257070-4255-2-git-send-email-nicolas.pitre@linaro.org> <20160919142553.3fb682ba@griffin> <alpine.LFD.2.20.1609190942230.9311@knanqh.ubzr> <20160919190415.26bd9343@griffin>
 <20160919173112.tpexkd44ggorg7ww@x>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jiri Benc <jbenc@redhat.com>, John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Richard Cochran <richardcochran@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kbuild@vger.kernel.org
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20160919173112.tpexkd44ggorg7ww@x>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Sep 2016, Josh Triplett wrote:

> But it does seem unfortunate that this can't happen at build time via
> Kconfig.  CCing linux-kbuild in case someone has an idea for how to fix
> this.

I hoped something like this could work:

config FOO
	prompt "Blah-blah"
	tristate if (BAR != y)
	bool if (BAR = y)
	default BAR

This way FOO could be y, m or n when BAR is m or n, otherwise FOO could 
be y or n only.

But that didn't work.


Nicolas
