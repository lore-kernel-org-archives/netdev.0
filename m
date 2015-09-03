From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net] switchdev: fix return value of switchdev_port_fdb_dump
 in case of error
Date: Thu, 3 Sep 2015 10:35:04 -0700
Message-ID: <CAE4R7bArJBH2AVR4FVQ=2dPZ=scE9CTuMDZoL_aXFX+UZEPf0Q@mail.gmail.com>
References: <1441281857-613-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33543 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbbICRfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 13:35:24 -0400
Received: by obbbh8 with SMTP id bh8so38616703obb.0
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2015 10:35:23 -0700 (PDT)
In-Reply-To: <1441281857-613-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 3, 2015 at 5:04 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> switchdev_port_fdb_dump is used as .ndo_fdb_dump. Its return value is
> idx, so we cannot return errval.
>
> Fixes: 45d4122ca7cd ("switchdev: add support for fdb add/del/dump via switchdev_port_obj ops.")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Scott Feldman<sfeldma@gmail.com>
