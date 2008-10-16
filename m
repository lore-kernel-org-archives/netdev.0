From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
 gc_elasticity is exceeded
Date: Wed, 15 Oct 2008 23:55:56 -0700 (PDT)
Message-ID: <20081015.235556.61915120.davem@davemloft.net>
References: <20081006225210.GA29794@hmsreliant.think-freely.org>
	<48EAEFF9.1000606@cosmosbay.com>
	<20081013182655.GA9505@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751957AbYJPG4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 02:56:20 -0400
In-Reply-To: <20081013182655.GA9505@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 13 Oct 2008 14:26:55 -0400

> If this meets everyones approval I think we can follow up with a
> patch to remove the secret interval code entirely.

This patch looks pretty good to me.

Just some minor coding style nits:

> +static void rt_secret_rebuild_oneshot(struct net *net) {

Openning brace on new line please.

> +static void rt_emergency_hash_rebuild(struct net *net) {

Likewise.
