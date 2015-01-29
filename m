From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: mark some potential candidates __read_mostly
Date: Thu, 29 Jan 2015 17:11:36 +0100
Message-ID: <54CA5BB8.1010204@redhat.com>
References: <1422530103-23869-1-git-send-email-dborkman@redhat.com> <1422546024.2861.18.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755023AbbA2QLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2015 11:11:42 -0500
In-Reply-To: <1422546024.2861.18.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2015 04:40 PM, Hannes Frederic Sowa wrote:
...
> Why not const?

Because all these candidates have a list member and are being
registered at respective places during __init/__exit. Similar
structs in other places already have __read_mostly, but these
ones can still be converted to it.

Cheers,
Daniel
