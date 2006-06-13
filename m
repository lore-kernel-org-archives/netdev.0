From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC/PATCH 2/2] update sunrpc to use in-kernel sockets API
Date: Mon, 12 Jun 2006 21:44:30 -0700
Message-ID: <448E42AE.1010901@us.ibm.com>
References: <1150156564.19929.33.camel@w-sridhar2.beaverton.ibm.com> <Pine.LNX.4.64.0606122320010.31627@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:36813 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932876AbWFMEof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 00:44:35 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0606122320010.31627@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Mon, 12 Jun 2006, Sridhar Samudrala wrote:
>
>   
>> -	sendpage = sock->ops->sendpage ? : sock_no_sendpage;
>> +	sendpage = kernel_sendpage ? : sock_no_sendpage;
>>     
>
> This is not equivalent.
>
>   
Actually, we could make this a simple assignment as we check for 
sock->ops->sendpage in
kernel_sendpage().
    sendpage = kernel_sendpage;

Thanks
Sridhar

