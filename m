From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: displayed name changed in ip link show for bridge- and other
 interfaces
Date: Mon, 15 Jun 2015 08:54:10 -0700
Message-ID: <20150615085410.6628b5bb@urahara>
References: <201506141200.20435.ulrich.gemkow@ikr.uni-stuttgart.de>
	<557DCD0A.5040500@hartkopp.net>
	<557DD20E.4080005@hartkopp.net>
	<557E7D89.30301@6wind.com>
	<557E9728.7080208@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34428 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755826AbbFOPyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 11:54:07 -0400
Received: by pdbki1 with SMTP id ki1so75756460pdb.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 08:54:07 -0700 (PDT)
In-Reply-To: <557E9728.7080208@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Jun 2015 11:13:12 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Theoretically, virtual interfaces should advertise an IFLA_LINK to 0.
> I don't know what is the best fix:
>   - patching iproute2 to avoid this '@NONE'
>   - patching the kernel (see below).


Sorry this is an ABI change. The kernel has to go back
to doing the same thing as before.
