From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2 v2] ss: Fix allocation of cong control alg name
Date: Fri, 29 May 2015 15:37:09 -0700
Message-ID: <1432939029.7456.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432922994-13735-1-git-send-email-vadim4j@gmail.com>
	 <20150529150209.07430666@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org,
	daniel@iogearbox.net, jose.r.guzman.mosqueda@intel.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:36493 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538AbbE2WhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 18:37:12 -0400
Received: by iepj10 with SMTP id j10so73320161iep.3
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 15:37:12 -0700 (PDT)
In-Reply-To: <20150529150209.07430666@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-29 at 15:02 -0700, Stephen Hemminger wrote:


> Why not use strdupa? I handles arbitrary size?

I doubt this will please security guys.

RETURN VALUE
       The alloca() function returns a pointer to the beginning of the
allocated space.  If the allocation causes stack overflow, program
behavior is undefined.


Could we please stick with this 16 bytes value ?

I am confident we wont increase kernel side because of various backward
compatibility issues anyway.
