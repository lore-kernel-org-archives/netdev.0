From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Mon, 18 Apr 2011 14:12:27 -0700
Message-ID: <BANLkTin_OgBo3N8qi5cF5rOd__pRKifwsg@mail.gmail.com>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	<1302253651.4409.2.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
	<1302267400.4409.22.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>
	<1302275223.4409.36.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>
	<1302330998.2656.113.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E48BA730@ESGSCCMS0001.eapac.ericsson.se>
	<4DA3151B.4030507@intel.com>
	<D12839161ADD3A4B8DA63D1A134D084026E4909714@ESGSCCMS0001.eapac.ericsson.se>
	<1302536577.4605.1.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E49535F2@ESGSCCMS0001.eapac.ericsson.se>
	<1302761251.3549.198.camel@edumazet-laptop>
	<1302762810.3549.233.camel@edumazet-laptop>
	<D12839161ADD3A4B8DA63D1A134D084026E49536AF@ESGSCCMS0001.eapac.ericsson.se>
	<4DA723F1.7000901@intel.com>
	<1302800202.2035.32.camel@laptop>
	<1302800221.3248.39.camel@edumazet-laptop>
	<1302857857.2388.158.camel@twins>
	<D12839161ADD3A4B8DA63D1A134D084026E4953D6E@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Mike Galbraith <efault@gmx.de>,
	Thomas Gleixner <tglx@linutronix.de>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44598 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675Ab1DRVM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 17:12:29 -0400
Received: by bwz15 with SMTP id 15so4205298bwz.19
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 14:12:27 -0700 (PDT)
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E4953D6E@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2011 at 2:14 AM, Wei Gu <wei.gu@ericsson.com> wrote:
> Is there something that I can provide in order to identify the problem?

for power state concerns you may want to try running turbostat
(available in recent kernels, runs also on older kernels) during the
workload in question.  Capture the results via something like:
cd /home/jbrandeb/linux-2.6.38.2/tools/power/x86/turbostat
make
for i in `seq 1 10` ; do ./turbostat -v sleep 5 >> turbostat.txt 2>&1 ; done

Jesse
