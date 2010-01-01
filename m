From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Thu, 31 Dec 2009 22:42:27 -0800
Message-ID: <4B3D9953.2030304@vyatta.com>
References: <4B3C8323.1080301@ring3k.org> <4B3CF2C4.5070203@gmail.com> <4B3D38FB.40105@ring3k.org> <4B3D66AA.3030709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mike McCormack <mikem@ring3k.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, dhazelton@enter.net, mbreuer@majjas.com
To: "Berck E. Nash" <flyboy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50942 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086Ab0AAGmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jan 2010 01:42:43 -0500
In-Reply-To: <4B3D66AA.3030709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Berck E. Nash wrote:
> Well, that didn't fix it.  Oops attached, looks pretty much the same to me.
>
>   
Not surprised really. What Mike saw is a real race, but unlikely because 
by the time timeout
happens the device is going to be quiet (no more traffic). 

