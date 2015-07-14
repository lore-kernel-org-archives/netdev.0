From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 1/4] net core: Add protodown support.
Date: Mon, 13 Jul 2015 18:09:48 -0700
Message-ID: <CACcJQnSnbCVXhLuVfSQF_T1NZS+yr8Ozzp_S+_1nOFWHN2gSoA@mail.gmail.com>
References: <1436481330-4599-2-git-send-email-anuradhak@cumulusnetworks.com>
	<20150713.143432.56479578476726354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:36205 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbbGNBJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 21:09:49 -0400
Received: by lbbpo10 with SMTP id po10so132120365lbb.3
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 18:09:48 -0700 (PDT)
In-Reply-To: <20150713.143432.56479578476726354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 13, 2015 at 2:34 PM, David Miller <davem@davemloft.net> wrote:
> From: anuradhak@cumulusnetworks.com
> Date: Thu,  9 Jul 2015 15:35:27 -0700
>
>> +/* proto_flags - port state information can be passed to the switch driver and
>> + * used to determine the phys state of the switch port */
>> +enum {
>> +     IF_PROTOF_DOWN          = 1<<0  /* set switch port phys state down */
>> +};
>
> Realistically, do we really foresee any other proto flags being added in
> the future?
>
> Unless there is a strong sense that we will have some, this is
> insanely overengineered with all of these bit masking capabilities and
> such and nested attributes.
>
> I'd say just do one boolean attribute and that's it.
Ack, I will resubmit with protodown as a boolean. Thanks for the review Dave.
