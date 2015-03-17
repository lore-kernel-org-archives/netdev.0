From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v3 2/3] rocker: add support for phys_port_name
Date: Tue, 17 Mar 2015 16:55:55 +0100
Message-ID: <20150317155555.GF2036@nanopsycho.lan>
References: <1426606258-13466-1-git-send-email-dsahern@gmail.com>
 <1426606258-13466-2-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sfeldma@gmail.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34950 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930AbbCQPz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 11:55:59 -0400
Received: by wibdy8 with SMTP id dy8so66944211wib.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 08:55:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426606258-13466-2-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 17, 2015 at 04:30:57PM CET, dsahern@gmail.com wrote:
>Implement the phys_port_name operation. Port names are pulled from the
>rocker hardware model in qemu and default to the qemu name + port id.
>e.g.,
>
>sw1p1: flags=4098<BROADCAST,MULTICAST>  mtu 1500
>        ether 52:54:00:12:35:01  txqueuelen 1000  (Ethernet)
>        RX packets 0  bytes 0 (0.0 B)
>        RX errors 0  dropped 0  overruns 0  frame 0
>        TX packets 0  bytes 0 (0.0 B)
>        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
>
>where 'sw1' comes from the qemu command line -device rocker,name=sw1, and
>'p1' is port 1.
>
>Patch is adapted from Scott's phys_port_id patch.
>
>v3:
>- updated per comments from Jiri and Philip regarding len type and
>  initializations
>
>v2:
>- updated per changes in prior patch requested by Jiri
>
>Signed-off-by: David Ahern <dsahern@gmail.com>
>Acked-by: Scott Feldman <sfeldma@gmail.com>
>Cc: Jiri Pirko <jiri@resnulli.us>


Acked-by: Jiri Pirko <jiri@resnulli.us>
