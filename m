From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Fri, 6 Feb 2015 08:10:46 +0200
Message-ID: <20150206081046.415c3d50@halley>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
	<54D3F8F9.2060500@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
	ebiederm@xmission.com, Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	hannes@stressinduktion.org, Eyal Birger <eyal.birger@gmail.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:53886 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbbBFGK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 01:10:57 -0500
Received: by mail-we0-f180.google.com with SMTP id m14so11677161wev.11
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 22:10:56 -0800 (PST)
In-Reply-To: <54D3F8F9.2060500@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 05 Feb 2015 15:12:57 -0800 roopa <roopa@cumulusnetworks.com> wrote:
> We have been playing with ip rules to implement vrfs. And the blocker 
> today is that we cannot bind a socket to a vrf (routing tables in this 
> case).

Hi Roopa,

One option would be using SO_MARK sockopt on that socket, and have an ip
rule which matches this mark to point to your table.
I don't know your exact use-cases, but you can play around with that
idea.

Regards,
Shmulik
