From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: How does the linux kernel select the MAC address for TAP devices?
Date: Mon, 16 Jun 2014 09:39:29 -0400
Message-ID: <539EF391.2040100@gmail.com>
References: <CAPRaSD6_TUBLNJu3GC84FwWmPOqLnhgmoq61mZX03dJFM8cyrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Albert Krenz <albert.krenz87@googlemail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:48422 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaFPNjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 09:39:33 -0400
Received: by mail-qa0-f45.google.com with SMTP id v10so7264217qac.4
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 06:39:32 -0700 (PDT)
In-Reply-To: <CAPRaSD6_TUBLNJu3GC84FwWmPOqLnhgmoq61mZX03dJFM8cyrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/16/2014 04:00 AM, Albert Krenz wrote:
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

Yes, it is explained in the source.  In particular look at the function
tun_net_init().  The default MAC is random.

-vlad
