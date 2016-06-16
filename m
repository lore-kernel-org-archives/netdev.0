From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [net-next PATCH v3 06/17] bnxt: Move GENEVE support from
 hard-coded port to using port notifier
Date: Thu, 16 Jun 2016 16:12:02 -0700
Message-ID: <CACKFLinup=5BsJrSiePpVGFdsRDq6wSxt_XnkiDG4LmujXZ0Cg@mail.gmail.com>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
	<20160616192136.20872.49824.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Jesse Gross <jesse@kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Dept-GELinuxNICDev@qlogic.com, David Miller <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:36715 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbcFPXMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 19:12:03 -0400
Received: by mail-oi0-f47.google.com with SMTP id p204so93011072oih.3
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 16:12:03 -0700 (PDT)
In-Reply-To: <20160616192136.20872.49824.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2016 at 12:21 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> The port number for GENEVE is hard coded into the bnxt driver.  This is the
> kind of thing we want to avoid going forward.  For now I will integrate
> this back into the port notifier so that we can change the GENEVE port
> number if we need to in the future.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Acked-by: Michael Chan <michael.chan@broadcom.com>
