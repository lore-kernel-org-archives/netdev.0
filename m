From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net 1/3] net: sctp: fix skb_over_panic when receiving
 malformed ASCONF chunks
Date: Sat, 11 Oct 2014 00:06:13 +0200
Message-ID: <54385855.10401@redhat.com>
References: <1412888133-833-1-git-send-email-dborkman@redhat.com> <1412888133-833-2-git-send-email-dborkman@redhat.com> <5437AF27.2030506@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Joshua Kinard <kumba@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27997 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599AbaJJWG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 18:06:26 -0400
In-Reply-To: <5437AF27.2030506@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2014 12:04 PM, Joshua Kinard wrote:
...
> If I am reading correctly, this crash can only be triggered by actually getting
> through the SCTP handshake, then sending this specially-crafted ASCONF chunk?
> Meaning a blind nmap scan using this tactic against a random netblock wouldn't
> just randomly knock servers offline?  This would seem to reduce the attack
> surface a quite bit by requiring the remote endpoint to actually respond.

Sorry, have been on travel almost whole day ... yes, handshake has to be
completed before that. So a scan/probe would need to establish a connection
first and ASCONF would need to be supported.

> Is there a CVE # for this?

CVE-2014-3673
