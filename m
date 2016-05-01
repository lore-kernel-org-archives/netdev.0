From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next PATCH v2 6/9] mlx4: Add support for inner IPv6 checksum
 offloads and TSO
Date: Sun, 1 May 2016 23:21:40 +0300
Message-ID: <CALzJLG-Vkx4oAeFecdYmr8Wfc2tPtbC=wWN7_qd+e5n+9fNGXA@mail.gmail.com>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server> <20160429224339.12418.53462.stgit@ahduyck-xeon-server>
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
Received: from mail-yw0-f194.google.com ([209.85.161.194]:32865 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbcEAUWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 16:22:00 -0400
Received: by mail-yw0-f194.google.com with SMTP id y6so16679034ywe.0
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 13:22:00 -0700 (PDT)
In-Reply-To: <20160429224339.12418.53462.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 30, 2016 at 1:43 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> >From what I can tell the ConnectX-3 will support an inner IPv6 checksum and
> segmentation offload, however it cannot support outer IPv6 headers.  This
> assumption is based on the fact that I could see the checksum being
> offloaded for inner header on IPv4 tunnels, but not on IPv6 tunnels.
>
> For this reason I am adding the feature to the hw_enc_features and adding
> an extra check to the features_check call that will disable GSO and
> checksum offload in the case that the encapsulated frame has an outer IP
> version of that is not 4.  The check in mlx4_en_features_check could be
> removed if at some point in the future a fix is found that allows the
> hardware to offload segmentation/checksum on tunnels with an outer IPv6
> header.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
