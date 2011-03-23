From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myri10ge: fix rmmod crash
Date: Wed, 23 Mar 2011 09:09:37 -0400
Message-ID: <4D89F111.7030506@myri.com>
References: <20110323124412.GA7813@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Brice Goglin <brice@myri.com>,
	stable@kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:35264 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932671Ab1CWNJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 09:09:42 -0400
Received: by qyg14 with SMTP id 14so7029600qyg.19
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 06:09:41 -0700 (PDT)
In-Reply-To: <20110323124412.GA7813@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/23/11 08:44, Stanislaw Gruszka wrote:
> Rmmod myri10ge crash at free_netdev() ->  netif_napi_del(), because napi
> structures are already deallocated. To fix call netif_napi_del() before
> kfree() at myri10ge_free_slices().

I apologize; I made a similar fix myself to our tree last fall simply
forgot to post it to netdev... I'm terribly sorry for the time
you wasted chasing this.   At any rate...

Acked by: Andrew Gallatin <gallatin@myri.com>


