From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next PATCH v2 8/9] mlx5e: Fix IPv6 tunnel checksum offload
Date: Sun, 1 May 2016 23:09:09 +0300
Message-ID: <CALzJLG88Xk3F1O1ANdJ7nmLscYfCFbtJh47FkB456W4F+ay_Ng@mail.gmail.com>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server> <20160429224352.12418.68373.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tal Alon <talal@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	michael.chan@broadcom.com, "David S. Miller" <davem@davemloft.net>,
	Gal Pressman <galp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:34589 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbcEAUJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 16:09:30 -0400
Received: by mail-yw0-f196.google.com with SMTP id i22so16790053ywc.1
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 13:09:30 -0700 (PDT)
In-Reply-To: <20160429224352.12418.68373.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 30, 2016 at 1:43 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> The mlx5 driver exposes support for TSO6 but not IPv6 csum for hardware
> encapsulated tunnels.  This leads to issues as it triggers warnings in
> skb_checksum_help as it ends up being called as we report supporting the
> segmentation but not the checksumming for IPv6 frames.
>
> This patch corrects that and drops 2 features that don't actually need to
> be supported in hw_enc_features since they are Rx features and don't
> actually impact anything by being present in hw_enc_features.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
