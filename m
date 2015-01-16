From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fq_codel with 802.15.4 6LoWPAN fragmentation issue
Date: Fri, 16 Jan 2015 05:00:11 -0800
Message-ID: <1421413211.11734.121.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150116120232.GD10068@omega>
	 <1421413071.11734.120.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wpan@vger.kernel.org,
	stephen@networkplumber.org, jukka.rissanen@linux.intel.com
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:59266 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755527AbbAPNAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 08:00:17 -0500
In-Reply-To: <1421413071.11734.120.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-16 at 04:57 -0800, Eric Dumazet wrote:
>  example :
> 

Sorry, one keyword was missing :

tc qdisc replace dev lowpan0 root fq_codel interval XXX
