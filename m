From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] include: add copy of tipc.h
Date: Mon, 6 Jul 2015 14:46:49 -0700
Message-ID: <20150706144649.5484bce6@urahara>
References: <20150629085315.B6DECA0BA1@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:32891 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753563AbbGFVqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 17:46:40 -0400
Received: by pdbdz6 with SMTP id dz6so17510228pdb.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 14:46:39 -0700 (PDT)
In-Reply-To: <20150629085315.B6DECA0BA1@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Jun 2015 10:53:15 +0200 (CEST)
Michal Kubecek <mkubecek@suse.cz> wrote:

> Copy of kernel include/uapi/linux/tipc.h is needed to build on systems
> with pre-3.16 kernel headers.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Ok, I applied (and fixed) this.
The headers you want are not directly from include/uapi/linux, instead
you need to run:
 $ make install_headers

Then copy the result out of usr/include/linux/ when getting a santized
header.
