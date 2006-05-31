From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH-2.4] forcedeth update to 0.50
Date: Wed, 31 May 2006 07:50:32 +0200
Message-ID: <447D2EA8.8020001@colorfullife.com>
References: <20060530220319.GA6945@w.ods.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: marcelo@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dbl.q-ag.de ([213.172.117.3]:36252 "EHLO dbl.q-ag.de")
	by vger.kernel.org with ESMTP id S932489AbWEaFuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 01:50:46 -0400
To: Willy Tarreau <willy@w.ods.org>
In-Reply-To: <20060530220319.GA6945@w.ods.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Willy,

Willy Tarreau wrote:

>I started from the latest backport you sent in september (0.42) and
>incrementally applied 2.6 updates. I stopped at 0.50 which provides
>VLAN support, because after this one, there are some 2.4-incompatible
>changes (64bit consistent memory allocation for rings, and MSI/MSIX
>support).
>
>  
>
I agree, 2.4 needs a backport. Either a full backport as you did, or a 
minimal one-liner fix.
Right now, the driver is not usable due to an incorrect initialization.
Or to be more accurate:
    # modprobe
    # ifup
works.
But
    # modprobe
    # ifup
    # ifdown
    # ifup
causes a misconfiguration, and the nic hangs hard after a few MB. And 
recent distros do the equivalent of ifup/ifdown/ifup somewhere in the 
initialization.

Marcelo: Do you need a one-liner, or could you apply a large backport patch?

--
    Manfred
