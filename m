From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v3 net-next 4/4] rocker: make
 rocker_port_internal_vlan_id_{get,put}() non-transactional
Date: Wed, 20 May 2015 08:02:04 +0200
Message-ID: <20150520060204.GD2228@nanopsycho.orion>
References: <1432100902-10187-1-git-send-email-simon.horman@netronome.com>
 <1432100902-10187-5-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33318 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502AbbETGCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 02:02:11 -0400
Received: by wicmx19 with SMTP id mx19so138467741wic.0
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 23:02:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432100902-10187-5-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 20, 2015 at 07:48:22AM CEST, simon.horman@netronome.com wrote:
>The motivation for this is that rocker_port_internal_vlan_id_{get,put} appear
>to only partially implement the transaction model: memory allocation
>and freeing is transactional, but hash and bitmap manipulation is not.
>
>The latter could be fixed, however, as it is not currently exercised
>due to trans always being SWITCHDEV_TRANS_NONE it seems cleaner
>to make rocker_port_internal_vlan_id_get non-transactional.
>
>Found by inspection.
>I do not believe that this change should have any run-time effect.
>
>Fixes: c4f20321d968 ("rocker: support prepare-commit transaction model")
>Acked-by: Scott Feldman <sfeldma@gmail.com>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
