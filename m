From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 2/4] switchdev: add fwd_mark generator helper
Date: Mon, 15 Jun 2015 08:17:34 -0700
Message-ID: <557EEC8E.9070206@cumulusnetworks.com>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com> <1434218670-43821-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	simon.horman@netronome.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33337 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbbFOPRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 11:17:35 -0400
Received: by pdjn11 with SMTP id n11so75119495pdj.0
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 08:17:35 -0700 (PDT)
In-Reply-To: <1434218670-43821-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/13/15, 11:04 AM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> skb->fwd_mark and dev->fwd_mark are 32-bit and should be unique for device
> and maybe even unique for a sub-set of ports within device, so add
> switchdev helper function to generate unique marks based on driver-supplied
> key.  Typically, the driver would use device switch ID for key, and maybe
> additional fields in key for grouped ports such as bridge ifindex.  The key
> can be of arbitrary length.
>
> The generator uses a global hash table to store fwd_marks hashed by key.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
