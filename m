From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] OVS Kernel Datapath development
Date: Mon, 8 Dec 2014 18:15:06 +0100
Message-ID: <20141208171506.GC2835@pox.localdomain>
References: <CALnjE+rn_Giv+8TM1_E2faBftRkivXMYHcjn-4Eq4Gu15r=CiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:53522 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaLHRPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 12:15:09 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so5471884wiw.4
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 09:15:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALnjE+rn_Giv+8TM1_E2faBftRkivXMYHcjn-4Eq4Gu15r=CiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/14 at 08:47pm, Pravin Shelar wrote:
> Since the beginning OVS kernel datapath development is primarily done
> on external OVS repo. Now we have mostly synced upstream and external
> OVS. So we have decided to change this process. New process is as
> follows.
> 
> 1. OVS feature development that involves kernel datapath should be
> done on net-next tree datapath.
> 2. Such feature patch series should be posted on netdev and ovs-dev
> mailing list.
> 3. Once review is done for entire series, kernel and OVS userspace
> patches will be merged in respective repo.
> 4. After the merge developer is suppose to send patches for external
> kernel datapath along with old kernel compatibility code. So that we
> can keep external datapath insync.

+1

Just to be clear, by respective repo do you mean net-next/net or will
you maintain a net-next branch on git.kernel.org and continue doing
pull requests?
