From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net] switchdev: check if the vlan id is in the proper vlan range
Date: Mon, 12 Oct 2015 22:42:04 -0700
Message-ID: <CAE4R7bBLUJ6mqjfeBX4ZBunpfJ+6gZoW4Hk3Rkz9eurCXtv9xA@mail.gmail.com>
References: <1444653061-5850-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:32992 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbbJMFmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 01:42:23 -0400
Received: by obbbh8 with SMTP id bh8so5606253obb.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 22:42:23 -0700 (PDT)
In-Reply-To: <1444653061-5850-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 5:31 AM, Nikolay Aleksandrov
<razor@blackwall.org> wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> VLANs 0 and 4095 are reserved and shouldn't be used, add checks to
> switchdev similar to the bridge. Also make sure ids above 4095 cannot
> be passed either.
>
> Fixes: 47f8328bb1a4 ("switchdev: add new switchdev bridge setlink")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
