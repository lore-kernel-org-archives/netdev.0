From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: e1000 Detected Tx Unit Hang
Date: Sun, 3 Sep 2006 10:45:49 -0700
Message-ID: <4807377b0609031045w67f70a3ese6bea93c15f75ba2@mail.gmail.com>
References: <002c01c6ce9d$a1cf9100$3224050a@avilespaxp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:44048 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751560AbWICRpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Sep 2006 13:45:51 -0400
Received: by ug-out-1314.google.com with SMTP id m3so1384730ugc
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2006 10:45:49 -0700 (PDT)
To: "Paul Aviles" <paul.aviles@palei.com>
In-Reply-To: <002c01c6ce9d$a1cf9100$3224050a@avilespaxp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/2/06, Paul Aviles <paul.aviles@palei.com> wrote:
> I am getting "e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang"  using
> stock 2.6.17.11, 2.6.17.5 or 2.6.17.4 kernels on centos 4.3.
>
>  The server is a Tyan GS12 ( 82541GI/PI and 82547GI) and is connected to a
> Netgear GS724T Gig  switch. I can easily reproduce the problem by trying to
> do a large ftp transfer to the server. It does not happen if the server is
> connected to a dummy 100 Mb switch, only when is connected to the Gig
> switch.
> I have also tried the options line below disabling tso, tx and rx in the
> modprobe.conf without any luck.

Hi Paul, sorry to hear about your problem.  You're getting hangs on
the 82547 right?  can you send the output of cat /proc/interrupts.
I'm curious if you are sharing interrupts while running NAPI.

Also, please try the driver without CONFIG_E1000_NAPI enabled in your
kernel .config, and let us know the results.

Someone has posted (what they think is) a theoretical problem with
irq_sem on the 82547 at e1000.sf.net and I haven't had a chance to
figure it out yet.

Jesse

-- 
VGER BF report: U 0.495355
