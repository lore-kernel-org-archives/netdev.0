From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: AF_PACKET how to get the original netdev from a packet received from a bonded master
Date: Wed, 18 Apr 2007 19:02:47 -0700
Message-ID: <41b516cb0704181902q646c4f9bvc34e79393ee974a3@mail.gmail.com>
References: <41b516cb0704181652o6a05b570t511ee23373a0b3ac@mail.gmail.com>
	 <20070418.170749.07021824.davem@davemloft.net>
	 <41b516cb0704181717l2c6c15a0j9ae275d15c6b22f4@mail.gmail.com>
	 <20070418.180622.35354420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chavey@google.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:54127 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031058AbXDSCCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 22:02:48 -0400
Received: by wr-out-0506.google.com with SMTP id 76so381659wra
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2007 19:02:48 -0700 (PDT)
In-Reply-To: <20070418.180622.35354420.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/18/07, David Miller <davem@davemloft.net> wrote:

> Ok, I'll try to remember to high-priority reviewing PJ's patch
> on my next rebase of the net-2.6.22 tree which should be
> tonight or tomorrow sometime.

Thanks Dave, PJ is offline this week so I'm trying to keep an eye out
for discussions related to his various patches :-)

Just to give you an idea of our motivation around this, we're looking
at layer 2 configuration protocols implemented from user space.  As an
example Link Layer Discovery Protocol could be used to detect trunking
misconfiguration, but only if you can track that information for the
underlying interfaces of a bond.  Things like 802.1x authenticated
links in a bond would have a similar issue of needing to configure
each underlying interface before bringing up the bond, but with LLDP
there's the added fun of being able to receive updated notifications
of configuration changes from the link partner at any time.

- Chris
