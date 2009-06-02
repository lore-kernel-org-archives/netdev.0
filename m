From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Tue, 02 Jun 2009 09:22:10 +0000
Message-ID: <1243934530.8439.4.camel@Maple>
References: <4A242161.3010609@cosmosbay.com> <4A242418.1090804@hp.com>
	 <1243907646.15854.16.camel@merlyn>
	 <20090601.190228.75178984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, dada1@cosmosbay.com, nicolas.dichtel@6wind.com,
	fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:51191 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941AbZFBJ2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 05:28:19 -0400
Received: by an-out-0708.google.com with SMTP id d40so16710319and.1
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2009 02:28:19 -0700 (PDT)
In-Reply-To: <20090601.190228.75178984.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-06-01 at 19:02 -0700, David Miller wrote:
> And I even remember there are applications that use multicast and
> a hop limit of zero explicitly to keep application traffic only on
> the local subnet.  So any change like that proposed could break
> things.

Are you thinking of multicast apps that explicitly set a hop limit, or Multicast
Listener Discovery?  The hop limit specified for MLDv2 messages is one,
not zero.

  --  John

