From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv2 net 2/3] openvswitch: Treat IP_CT_RELATED as new
Date: Tue, 20 Oct 2015 02:25:42 +0200
Message-ID: <20151020002542.GD7104@pox.localdomain>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
 <1445018901-18839-3-git-send-email-joestringer@nicira.com>
 <20151017075233.GC13981@pox.localdomain>
 <CANr6G5xmO6D0Yu0VXeaJLbO1aK2tQ5_vHUNRkawK1zNFMJz=aw@mail.gmail.com>
 <20151019090332.GA7104@pox.localdomain>
 <CANr6G5wLhz6UcBp0_a_cCnofJFyY43CU290Uu8+RKiDmUZccqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jrajahalme@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33814 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbbJTAZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 20:25:45 -0400
Received: by wikq8 with SMTP id q8so22416359wik.1
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 17:25:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CANr6G5wLhz6UcBp0_a_cCnofJFyY43CU290Uu8+RKiDmUZccqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/15 at 04:13pm, Joe Stringer wrote:
> I think that the proper solution instead of this patch is to set NEW
> if !nf_ct_is_confirmed(ct). This is more accurately the meaning for
> 'NEW' that we are actually trying to expose. As long as this is done
> before confirming the connection during a "commit", this will make the
> behaviour consistent with the lack of commit flag. I'm sending a
> patch. Thanks for the feedback!

Agreed. This sounds perfect.
