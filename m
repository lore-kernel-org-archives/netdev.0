From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v3 net-next 5/8] geneve: Add support to collect tunnel
 metadata.
Date: Tue, 25 Aug 2015 19:48:01 +0200
Message-ID: <20150825174801.GD3707@pox.localdomain>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
 <1440438195-5695-6-git-send-email-pshelar@nicira.com>
 <CAEP_g=_iA6FA4wboFpd_dRXnhQs4u9H7XFv5ACopv-2gy6g5Ew@mail.gmail.com>
 <CALnjE+pH3es+bSjVTGohr4xNatB=BTXcVQg3DPLwzHCr6nbz4w@mail.gmail.com>
 <CAEP_g=9Fpb9KOeqeeK_dbCdec8TvHm-iUZ4V_MWj1Mc21Qa9OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin Shelar <pshelar@nicira.com>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:37168 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754237AbbHYRsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 13:48:04 -0400
Received: by widdq5 with SMTP id dq5so21984896wid.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 10:48:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAEP_g=9Fpb9KOeqeeK_dbCdec8TvHm-iUZ4V_MWj1Mc21Qa9OQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/15 at 09:50am, Jesse Gross wrote:
> On Mon, Aug 24, 2015 at 7:15 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> > Moving this device means moving all tunnels backed by this device
> > rather than specific tunnel device. Thats why it does not look right
> > to move such device.
> 
> I agree it seems weird in general. There were two things that made me wonder:
>  * It doesn't appear that VXLAN or GRE do this.
>  * The use case for moving a single tunnel to a different namespace is
> to have the device and socket live in different places. I guess
> conceptually this could apply to collect_md devices as well. (Maybe to
> have harder isolation between inside and outside the tunnel?)
> 
> I'm not really sure what the best answer is but at least we should be
> consistent across tunnel types.

I agree with Jesse that consistent behaviour is desirable. If needed,
let's change it for all encap types.
