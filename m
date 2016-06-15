From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH v2 06/17] bnxt: Move GENEVE support from
 hard-coded port to using port notifier
Date: Wed, 15 Jun 2016 16:19:59 -0700
Message-ID: <CAKgT0UfPFjy7_wuzzfgbPbnyBzZ+grUOnykEbrYSw4=EvhTVFA@mail.gmail.com>
References: <20160615220449.15575.17031.stgit@localhost.localdomain> <20160615220754.15575.94576.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Jesse Gross <jesse@kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Benc <jbenc@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Michael Chan <michael.chan@broadcom.com>,
	Dept-GELinuxNICDev@qlogic.com, David Miller <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:32787 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161AbcFOXUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 19:20:00 -0400
Received: by mail-io0-f170.google.com with SMTP id t74so27503678ioi.0
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 16:20:00 -0700 (PDT)
In-Reply-To: <20160615220754.15575.94576.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 3:07 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> The port number for GENEVE is hard coded into the bnxt driver.  This is the
> kind of thing we want to avoid going forward.  For now I will integrate
> this back into the port notifier so that we can change the GENEVE port
> number if we need to in the future.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

So it turns out this patch doesn't apply on top of the current tree.
I will submit a v3 of these patches tomorrow after everyone has had a
chance to review.

- Alex
