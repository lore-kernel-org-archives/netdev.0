From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 03/12] i40e: Handle a single mss packet with more
 than 8 frags
Date: Mon, 17 Nov 2014 08:58:04 -0800
Message-ID: <1416243484.5102.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <FC41C24E35F18A40888AACA1A36F3E418AD8F543@fmsmsx115.amr.corp.intel.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9F1F9F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'Nelson, Shannon'" <shannon.nelson@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kong, Serey" <serey.kong@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:46606 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbaKQQ6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 11:58:00 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so5475755igd.13
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 08:58:00 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9F1F9F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-17 at 16:16 +0000, David Laight wrote:

> Except that a TSO packet is likely to be just under 64k and comprise of
> a small header and 16 other fragments - most of which will be a complete 4k page.
> 

This is the section of the code sending a _non_ TSO packet.
