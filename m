From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: packet tracing
Date: Thu, 7 May 2015 09:57:43 +0200
Message-ID: <20150507075743.GE21015@haze>
References: <CABqzqi5f7JMY7MLXxeUn1_vdO9j0uL3-_eZ8fdp349rX1Kz7cg@mail.gmail.com>
 <20150507062655.GB21015@haze>
 <CABqzqi486+ET65Eyyy4R26ic_S_mi+w6nd70gfzsMwdt7nLiLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: sainath grandhi <saiallforums@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:50372 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbbEGIC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:02:57 -0400
Content-Disposition: inline
In-Reply-To: <CABqzqi486+ET65Eyyy4R26ic_S_mi+w6nd70gfzsMwdt7nLiLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 06, 2015 at 11:52:57PM -0700, sainath grandhi wrote:
> Hi Erik,
>    Are you referring to something like this?
> 
> iptables -A LOGGING -j LOG

Ex. log all L2 packets (raw/prerouting)
iptables -t raw -A PREROUTING -j LOG

I refer to this a lot (not sure if it's 100% accurate anymore though)
http://upload.wikimedia.org/wikipedia/commons/3/37/Netfilter-packet-flow.svg
