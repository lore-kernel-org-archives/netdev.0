From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv4 net-next 0/2] Add two new flags to bridge.
Date: Wed, 05 Jun 2013 18:14:11 +0400
Message-ID: <51AF47B3.2070902@cogentembedded.com>
References: <1370441281-11281-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	shemminger@vyatta.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:47384 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237Ab3FEOOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 10:14:11 -0400
Received: by mail-lb0-f177.google.com with SMTP id 10so1508133lbf.22
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 07:14:09 -0700 (PDT)
In-Reply-To: <1370441281-11281-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05-06-2013 18:07, Vlad Yasevich wrote:

> The following series adds 2 new flags to bridge.  One flag allows
> the user to control whether mac learning is performed on the interface
> or not.  By default mac learning is on.
> The other flag allows the user to control whether unicast traffic
> is flooded (send without an fdb) to a given unicast port.  Default is
> on.

> Changes since v4:
>   - Implemented Stephen's suggestions.

> Changes since v2:
>   - removed unused "unlock" tag.

> Changes since v1:
>   - Integrated suggestion from MST to not impact RTM_NEWNEIGH and to
>     skip lookups when learning is disabled.

> Vlad Yasevich (2):
>    bridge: Add flag to control mac learning.
>    bridge: Add a flag to control unicast packet flood.

> Vlad Yasevich (2):
>    bridge: Add flag to control mac learning.
>    bridge: Add a flag to control unicast packet flood.

     Hm, why your patches are listed twice?

WBR, Sergei
