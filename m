From: "Jon Nelson" <jnelson@jamponi.net>
Subject: Re: [Bugme-new] [Bug 9391] New: Netgear GA320T(tg3) strange errors and non-workingness
Date: Fri, 16 Nov 2007 08:08:16 -0600
Message-ID: <cccedfc60711160608j1ff89979uf7c1f122dd050adc@mail.gmail.com>
References: <20071115181809.592a110c.akpm@linux-foundation.org>
	 <20071116083007.GA2124@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	mchan@broadcom.com, "Andrew Morton" <akpm@linux-foundation.org>
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:20781 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbXKPOIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 09:08:24 -0500
Received: by ug-out-1314.google.com with SMTP id z38so647468ugc
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2007 06:08:22 -0800 (PST)
In-Reply-To: <20071116083007.GA2124@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/16/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> On 16-11-2007 03:18, Andrew Morton wrote:
> > On Thu, 15 Nov 2007 18:04:19 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> >
> >> http://bugzilla.kernel.org/show_bug.cgi?id=9391
> >>
> >>            Summary: Netgear GA320T(tg3) strange errors and non-workingness
> >>            Product: Drivers
> >>            Version: 2.5
> >>      KernelVersion: 2.6.22.12 (openSUSE 10.3)
> ...
>
> I see we have a new thread for this...
>
> Jon, maybe it's only me, but this really looks strange. I don't know
> this board, but probably these interrupts shouldn't look like this.
> It seems there is a problem with detecting your apic. I'm not sure
> if this is a default SUSE kernel, but maybe it would be better to
> try some current live-cd distro with good hardware detection. tg3
> card & driver seem to have quite good opinions, especially if msi
> interrupts could be used.
>
> Btw., these logs (dmesg, lspci) could be much longer... (Somebody
> might even think you have something to hide; it would be better to
> mask only personal data then.)

The lspci is exactly as it was output. The dmesg is shortened only
slightly. The kernel is the latest available for openSUSE 10.3. No MSI
because this is an Athlon XP (read: 32bit, single core, regular old
33MHz, 32bit PCI).

The interrupts look *exactly* the same with or without noapic. This
board doesn't have apic as far as I know. It's an ECS K7S5A I think.

Does that help?

-- 
Jon
