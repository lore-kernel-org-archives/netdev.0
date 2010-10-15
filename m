From: Elly Jones <ellyjones@google.com>
Subject: Re: [PATCH v2] Add Qualcomm Gobi 2000 driver.
Date: Fri, 15 Oct 2010 09:17:28 -0400
Message-ID: <20101015131727.GA12670@google.com>
References: <20101006151208.GB1571@google.com> <20101008.102803.104075511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jglasgow@google.com, mjg59@srcf.ucam.org,
	msb@google.com, olofj@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:15042 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651Ab0JONRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 09:17:38 -0400
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o9FDHag0027942
	for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 06:17:36 -0700
Received: from iwn39 (iwn39.prod.google.com [10.241.68.103])
	by wpaz9.hot.corp.google.com with ESMTP id o9FDHYG5028244
	for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 06:17:35 -0700
Received: by iwn39 with SMTP id 39so1043065iwn.12
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 06:17:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101008.102803.104075511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 08, 2010 at 10:28:03AM -0700, David Miller wrote:
> From: Elly Jones <ellyjones@google.com>
> Date: Wed, 6 Oct 2010 11:12:09 -0400
> 
> > From: Elizabeth Jones <ellyjones@google.com>
> > 
> > This driver is a rewrite of the original Qualcomm GPL driver, released as part
> > of Qualcomm's "Code Aurora" initiative. The driver has been transformed into
> > Linux kernel style and made to use kernel APIs where appropriate; some bugs have
> > also been fixed. Note that the device in question requires firmware and a
> > firmware loader; the latter has been written by mjg (see
> > http://www.codon.org.uk/~mjg59/gobi_loader/).
> > 
> > Special thanks go to Joe Perches <joe@perches.com> for major cleanup.
> > 
> > Signed-off-by: Elizabeth Jones <ellyjones@google.com>
> > Signed-off-by: Jason Glasgow <jglasgow@google.com>
> 
> I really think the firmware handling belongs in the kernel.
> 
> I've looked at the gobi_loader code and it's simpler than many
> of the gigabit ethernet driver firmware loader sequences in
> the tree already.
> 
> Requiring udev et al. magic only makes this networking device
> that much harder to use from an initrd.
> 
> I understand how this might be a bit clumsy since we'd need to make a
> dependency on the serial device since that is the mechanism by which
> the firmware is uploaded, but really I'd like you to consider it
> seriously.

Just to respond definitively to this: I believe the reasons mjg59 brought up are
valid and I will not try to put a firmware loader for this device in kernel
space. Additionally, Google could not in good conscience produce such a firmware
loader, as we have access to Qualcomm's closed-source firmware loader. Expect a
v3 of this patch shortly to address Joe Perches' concerns.

-- Elly
