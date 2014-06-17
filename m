From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: How does the linux kernel select the MAC address for TAP devices?
Date: Tue, 17 Jun 2014 12:25:29 +0200
Message-ID: <53A01799.5060304@redhat.com>
References: <CAPRaSD6_TUBLNJu3GC84FwWmPOqLnhgmoq61mZX03dJFM8cyrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Albert Krenz <albert.krenz87@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753935AbaFQKZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2014 06:25:33 -0400
In-Reply-To: <CAPRaSD6_TUBLNJu3GC84FwWmPOqLnhgmoq61mZX03dJFM8cyrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/16/2014 10:00 AM, Albert Krenz wrote:
> As stated in the email subject: Where does the kernel get the used
> MAC-Adress for a newly create TAP device? Are they randomly generated
> or does it select one from a fixed pool of reserved MAC-Adresses?
>
> I have not found any official documentation about the selection of
> MAC-addresses for TAP-devices. Most sites like
> http://backreference.org/2010/03/26/tuntap-interface-tutorial/ state
> that the MAC addresses are auto-generated and can be changed. But they
> do not explain the generation rules.
>
> Does anyone know an official document (preferably from kernel.org)
> explaining the MAC selection process? Or is it only explained in the
> Source?

See: drivers/net/tun.c +936
