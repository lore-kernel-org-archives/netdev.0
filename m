From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 1/9] i40e: poll firmware slower
Date: Fri, 7 Nov 2014 15:29:15 +0200
Message-ID: <CAJ3xEMghFwT8Tm9wONzLPL4MLvgL+3w=CNRNg0Hb=yGJ9uR0Mg@mail.gmail.com>
References: <1415350670-15333-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1415350670-15333-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Kamil Krawczyk <kamil.krawczyk@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:51065 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbaKGN3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 08:29:16 -0500
Received: by mail-oi0-f45.google.com with SMTP id v63so2375648oia.32
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 05:29:15 -0800 (PST)
In-Reply-To: <1415350670-15333-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 7, 2014 at 10:57 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> The code was polling the firmware tail register for completion

any reason not to sleep while waiting for this completion? can the
firmware generate an interrupt?
