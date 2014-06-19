From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next 1/8] flow_keys: Record IP layer protocol in
 skb_flow_dissect()
Date: Fri, 20 Jun 2014 00:22:22 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1406200018500.7347@ws.cisco>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com> <1402338773-5996-2-git-send-email-_govind@gmx.com> <CAEb0Mfc6Q5uO2dexTtsT4paXpqHKKGfJimgX0Wipebapncv5hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, benve@cisco.com
To: Chema Gonzalez <chema@berkeley.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:60313 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934242AbaFSSw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2014 14:52:58 -0400
In-Reply-To: <CAEb0Mfc6Q5uO2dexTtsT4paXpqHKKGfJimgX0Wipebapncv5hw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jun 2014, Chema Gonzalez wrote:
> If you add n_proto, have you considered adding nhoff too? That way the
> L3 and L4 headers will be completely pinned by the flow dissector.
>

Yes, I have actually considered it. But right now there is no one who would need
nhoff. We can add it later when we need it?

Thanks
