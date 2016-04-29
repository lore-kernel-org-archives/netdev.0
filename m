From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 00/11] Mellanox 100G extending mlx5 ethtool support
Date: Sat, 30 Apr 2016 00:14:00 +0300
Message-ID: <CALzJLG8ieHkdGf9xhYOzKA3dRgR6ROFUd6=t4McHJM+XmX+WwQ@mail.gmail.com>
References: <CALzJLG-BJvB7h2wAOqy8ibDdkw7Croaiy7+QU9izrcivuS1yOg@mail.gmail.com>
 <20160426.174150.2239494413467110.davem@davemloft.net> <CALzJLG_a4s54MwCzOHMeCp0i5F5pyb-PHY_AFA-ok2JT5S62wQ@mail.gmail.com>
 <20160429.163446.928550855039136205.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:36589 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378AbcD2VOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 17:14:25 -0400
Received: by mail-yw0-f176.google.com with SMTP id o66so210155593ywc.3
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 14:14:20 -0700 (PDT)
In-Reply-To: <20160429.163446.928550855039136205.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2016 at 11:34 PM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
> Date: Fri, 29 Apr 2016 23:27:06 +0300
>
>> but my concerns is when features A and B requires firmware commands A then B
>> and firmware command B fails, there is no gurantee that roll back for
>> firmware command A will work.
>>
>> this is why in case of B fails we keep the state (new A and prev B)
>> rather than try to go back to (prev A and prev B).
>
> That's a limitation of your firmware I would say.
>
> Users do not expect the semantics you will be providing, if "change A and B"
> fails both states must not be changed.
>
> This is an unwavering requirement, you must do everything you can to
> meet that expection.
>
> You cannot say "our firmware does this so, you might get partial
> updates."  That simply is not acceptable.

Got it, we'll revisit this area of code and make meet the requirement.

Thank you Dave.
