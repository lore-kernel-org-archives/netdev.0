From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH 1/2] ptp_clock: allow for it to be optional
Date: Mon, 19 Sep 2016 14:25:53 +0200
Message-ID: <20160919142553.3fb682ba@griffin>
References: <1474257070-4255-1-git-send-email-nicolas.pitre@linaro.org>
        <1474257070-4255-2-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Richard Cochran <richardcochran@gmail.com>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474257070-4255-2-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 18 Sep 2016 23:51:09 -0400, Nicolas Pitre wrote:
> And to make it possible for PTP to be configured out, the select statement
> in the Kconfig entry for those ethernet drivers is changed from selecting
> PTP_1588_CLOCK to PTP_1588_CLOCK_SELECTED whose purpose is to indicate the
> default Kconfig value for the PTP subsystem.

With this patch applied, the user is free to set a NIC driver as built
in and PTP_1588_CLOCK as a module, right? If so, that would lead to
non-functional PTP without any warning due to the use of IS_REACHABLE.
That doesn't sound right. Could easily cause hours of headache to
someone.

Or is this handled somehow?

Thanks,

 Jiri
