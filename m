From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC] switchdev: generate phys_port_name in the core
Date: Thu, 27 Jul 2017 19:37:55 -0700
Message-ID: <20170727193755.34e055ea@cakuba.netronome.com>
References: <CAJ3xEMhUs0DfMioSU=gqR_hEs=ZFjUM1bA3nA9LwtTgH93ygDQ@mail.gmail.com>
        <20170728023122.1674-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        David Miller <davem@davemloft.net>, simon.horman@netronome.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34675 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751744AbdG1Ch6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 22:37:58 -0400
Received: by mail-pg0-f52.google.com with SMTP id 123so105232874pgj.1
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 19:37:58 -0700 (PDT)
In-Reply-To: <20170728023122.1674-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Jul 2017 19:31:22 -0700, Jakub Kicinski wrote:
> +static size_t rtnl_port_info_size(void)
> +{
> +	size_t port_info_size = nla_total_size(0) + /* nest IFLA_PORT_INFO */

				nla_total_size(4) + /* TYPE */

> +				nla_total_size(4) + /* EXTERNAL_ID or PF_ID */
> +				nla_total_size(4);  /* SPLIT_ID or VF_ID*/
> +
> +	return port_info_size;
> +}
> +
