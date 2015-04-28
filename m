From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next v3 0/4] net: Introduce IFF_PROTO_DOWN flag.
Date: Mon, 27 Apr 2015 22:45:46 -0700
Message-ID: <CAE4R7bAGRKGShQuSqjvQDW8cG6MHE8Jie7Hp=7FJw00kJM4NgQ@mail.gmail.com>
References: <1430156304-13187-1-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: anuradhak@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:33215 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbbD1Fpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 01:45:46 -0400
Received: by qgdy78 with SMTP id y78so59013208qgd.0
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 22:45:46 -0700 (PDT)
In-Reply-To: <1430156304-13187-1-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2015 at 10:38 AM,  <anuradhak@cumulusnetworks.com> wrote:
> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>
> User space daemons can detect errors in the network that need to be
> notified to the switch device drivers.
>
> Drivers can react to this error state by doing a phy-down on the
> switch-port which would result in a carrier-off locally and on the
> directly connected switch. Doing that would prevent loops and
> black-holes in the network.

(Sorry if this was asked earlier)

Can the application simply send a SETLINK with IFF_UP clear and the
port driver's ndo_stop would bring the PHY link down?
