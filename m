From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] htb: report overhead attribute
Date: Mon, 03 Jun 2013 08:56:02 -0700
Message-ID: <1370274962.24311.156.camel@edumazet-glaptop>
References: <20130529151330.22c5c89e@redhat.com>
	 <1370207755.24311.81.camel@edumazet-glaptop>
	 <1370208781.24311.89.camel@edumazet-glaptop> <51ACB9FE.1020100@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:56487 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758763Ab3FCP4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 11:56:06 -0400
Received: by mail-pa0-f44.google.com with SMTP id wp1so954530pac.31
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 08:56:04 -0700 (PDT)
In-Reply-To: <51ACB9FE.1020100@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 08:45 -0700, Rick Jones wrote:

> Is it (still) possible to have a negative overhead?
> 
> http://www.linksysinfo.org/index.php?threads/speedmod-with-tc-atm-qos-patch-for-adsl.31541/

overhead always has been unsigned in the kernel.

What you describe is a userland hack in tc command.

(or a bug)
