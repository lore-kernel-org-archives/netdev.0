From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH iproute2 3/3] ip netns: Delete all netns
Date: Wed, 07 Jan 2015 10:44:24 -0500
Message-ID: <54AD5458.6000400@hp.com>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com> <1420628662-9930-4-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:35071 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747AbbAGPo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 10:44:26 -0500
In-Reply-To: <1420628662-9930-4-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2015 06:04 AM, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Allow delete all namespace names by:
> 
>     $ ip netns del all

So I can still create a namespace called 'all', but can't exec in it or delete
it independently with this change.  Perhaps you need to block that as well?
Unless there's some other patch I'm missing?

-Brian
