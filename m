From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v5 net-next 5/8] geneve: Add support to collect tunnel
 metadata.
Date: Fri, 28 Aug 2015 12:22:13 +0200
Message-ID: <20150828102213.GG32206@pox.localdomain>
References: <1440658015-13028-1-git-send-email-pshelar@nicira.com>
 <1440658015-13028-6-git-send-email-pshelar@nicira.com>
 <20150827091854.GD18481@pox.localdomain>
 <CALnjE+pDWPEbuZ1--bk433x39BXvkf6ZcMcfhbg45DZBMV+HBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34975 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbbH1KWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 06:22:15 -0400
Received: by wicne3 with SMTP id ne3so15788176wic.0
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 03:22:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALnjE+pDWPEbuZ1--bk433x39BXvkf6ZcMcfhbg45DZBMV+HBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/15 at 02:29pm, Pravin Shelar wrote:
> On Thu, Aug 27, 2015 at 2:18 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > It is slightly non obvious that introducing an error condition above
> > this and before udp_tun_rx_dst() would introduce a memory leak. Other
> > than this looks great now.
> >
> I can not move this into if condition block since skb-scrub-packet
> drops skb dst entry.

I understand, VXLAN does the same. A comment would help though.
