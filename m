From: Patrick McHardy <kaber@trash.net>
Subject: Re: "kernel:nf_ct_icmp: bad HW ICMP checksum" too noisy
Date: Thu, 15 Apr 2010 16:34:22 +0200
Message-ID: <4BC723EE.9090504@trash.net>
References: <m31vegztav.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m31vegztav.fsf@ursa.amorsen.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benny Amorsen wrote:
> Would it be possible to lower the log level of "kernel:nf_ct_icmp: bad
> HW ICMP checksum" so that they don't show up on the console? Obviously I
> could configure rsyslog to never send anything to the console, but then
> I might miss something which is actually critical.

Yeah, I guess defaulting to KERN_EMERG wasn't the best choice :)
I'll lower it to something reasonable - I guess KERN_NOTICE would
be appropriate.

> It's obviously nice to know about corrupted ICMP on a controlled LAN,
> but on the open Internet you can't really do anything about it.

You should only see that message when nf_conntrack_log_invalid is
active.
